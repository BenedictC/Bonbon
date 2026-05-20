import UIKit


public typealias CollectionViewDiffableDataSourceIndexElement = (title: String, indexPath: IndexPath)


public final class CollectionViewDiffableDataSource<SectionIdentifierType: Hashable, ItemIdentifierType: Hashable>: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType> {

    // MARK: Types

    public typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    public typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemIdentifierType>

    public typealias IndexElement = CollectionViewDiffableDataSourceIndexElement
    public typealias IndexElementsProvider = (NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>) -> [IndexElement]

    typealias SupplementaryViewConfiguration = UICandy.SupplementaryRegistration<SectionIdentifierType, ItemIdentifierType>
    typealias SupplementaryRegistrationProvider = ((String, IndexPath) -> (SupplementaryRegistration<SectionIdentifierType, ItemIdentifierType>)?)


    // MARK: Properties

    public var indexElementsProvider: IndexElementsProvider? {
        didSet { collectionView?.reloadData() }
    }
    private var cachedIndexElements: [IndexElement]?

    private weak var collectionView: UICollectionView?

    // Visible views refreshing
    private var supplementaryElementKinds: [String]?
    private var supplementaryRegistrationProvider: SupplementaryRegistrationProvider?

    // Queue
    private var pendingTransactions = [AnyTransaction]()
    private var currentTransaction: AnyTransaction?



    // MARK: Instance life cycle

    public override init(collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>.CellProvider) {
        self.collectionView = collectionView
        super.init(collectionView: collectionView, cellProvider: cellProvider)
    }


    // MARK: UICollectionViewDataSource overrides

    @MainActor
    public override func indexTitles(for collectionView: UICollectionView) -> [String]? {
        guard let indexElementsProvider else {
            cachedIndexElements = nil
            return nil
        }
        let snapshot = self.snapshot()
        let indexElements = indexElementsProvider(snapshot)
        self.cachedIndexElements = indexElements
        return indexElements.map { $0.title }
    }

    public override func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        guard let cachedIndexElements else {
            // This shouldn't happen, but if it does go to the first item in the layout
            return IndexPath(item: 0, section: 0)
        }
        return cachedIndexElements[index].indexPath
    }
}


// MARK: - Supplementary View reconfiguration

public extension CollectionViewDiffableDataSource {

    internal func setSupplementaryElementKinds(
        _ supplementaryElementKinds: [String],
        supplementaryRegistrationProvider: @escaping SupplementaryRegistrationProvider
    ) {
        self.supplementaryElementKinds = supplementaryElementKinds
        self.supplementaryRegistrationProvider = supplementaryRegistrationProvider
    }

    func reconfigureCells() {
        var fresh = snapshot()
        fresh.reconfigureItems(fresh.itemIdentifiers)
        apply(fresh)
    }

    func reconfigureSupplementaryViews() {
        guard let collectionView,
              let supplementaryElementKinds,
              let supplementaryRegistrationProvider
        else {
            return
        }
        let snapshot = self.snapshot()

        let sections = snapshot.sectionIdentifiers
        let supplementaryViewInfoTuples = supplementaryElementKinds
            .flatMap { elementKind -> [(String, IndexPath)] in
                let indexPaths = collectionView.indexPathsForVisibleSupplementaryElements(ofKind: elementKind)
                return indexPaths.map { (elementKind, $0) }
            }
            .compactMap { pair -> (String, IndexPath, SectionIdentifierType, ItemIdentifierType?)? in
                let (elementKind, indexPath) = pair
                let section = sections[indexPath.section]
                let items = snapshot.itemIdentifiers(inSection: section)
                let item = indexPath.item < items.count ? items[indexPath.item] : nil
                return (elementKind, indexPath, section, item)
            }

        for tuple in supplementaryViewInfoTuples {
            let (elementKind, indexPath, section, item) = tuple
            guard
                let view = collectionView.supplementaryView(forElementKind: elementKind, at: indexPath),
                let configuration = supplementaryRegistrationProvider(elementKind, indexPath)
            else {
                continue
            }
            configuration.configureSupplementaryView(view, indexPath: indexPath, section: section, item: item)
        }
    }
}


// MARK: - Transaction Queue

public enum CollectionViewDiffableDataSourceQueueMode {
    case append, clear
}


public extension CollectionViewDiffableDataSource {

    // MARK: Transaction types

    typealias QueueMode = CollectionViewDiffableDataSourceQueueMode
    typealias TransactionContext = CollectionViewDiffableDataSourceTransactionContext<SectionIdentifierType, ItemIdentifierType>

    class Transaction<T> {

        let actions: (TransactionContext) async -> T
        private var task: Task<T, Never>!
        private var continuation: CheckedContinuation<T, Never>!

        init(actions: @escaping (TransactionContext) async -> T) {
            self.actions = actions
            self.task = Task {
                await withCheckedContinuation { continuation in
                    self.continuation = continuation
                }
            }
        }

        func execute(context: TransactionContext) async {
            let value = await actions(context)
            continuation.resume(returning: value)
        }

        func result() async -> T {
            await task.value
        }
    }

    struct AnyTransaction {
        let executeHandler: (_ context: TransactionContext) async -> Void
        func execute(context: TransactionContext) async {
            await executeHandler(context)
        }
    }


    // MARK: Transaction management

    func enqueue(withMode mode: QueueMode, transaction: @escaping (TransactionContext) async -> Void) {
        Task {
            await enqueue(withMode: mode, transaction: transaction)
        }
    }

    @discardableResult
    func enqueue<T>(withMode mode: QueueMode, transaction actions: @escaping (TransactionContext) async -> T) async -> T {
        // Update queue
        if mode == .clear {
            pendingTransactions.removeAll()
        }
        // Create transaction
        let transaction = Transaction(actions: actions)
        let anyTransaction = AnyTransaction(executeHandler: { await transaction.execute(context: $0) })
        pendingTransactions.append(anyTransaction)

        // Wait for result
        dequeueNextTransaction()
        return await transaction.result()
    }

    private func dequeueNextTransaction() {
        // Is ready?
        let isIdle = currentTransaction == nil
        guard isIdle, !pendingTransactions.isEmpty else {
            return
        }

        // Dequeue
        let transaction = pendingTransactions.removeFirst()
        currentTransaction = transaction

        // Execute
        Task { @MainActor in
            let context = TransactionContext(dataSource: self, collectionView: collectionView!)
            await transaction.execute(context: context)
            currentTransaction = nil
            // Next!
            dequeueNextTransaction()
        }
    }
}


// MARK: - Factory

public extension CollectionViewDiffableDataSource {

    func newSnapshot() -> Snapshot {
        Snapshot()
    }
}


// MARK: - Backport for iOS 14

internal extension UICollectionViewDiffableDataSource {

    func sectionIdentifier(forSectionAtIndex sectionIndex: Int) -> SectionIdentifierType? {
        let snapshot = self.snapshot()
        guard sectionIndex < snapshot.sectionIdentifiers.count else {
            return nil
        }
        return snapshot.sectionIdentifiers[sectionIndex]
    }
}



// MARK: - NSDiffableDataSourceSnapshot

public extension NSDiffableDataSourceSnapshot {

    mutating func reset() {
        self = Self()
    }

    func deletingAllItems() -> Self {
        Self()
    }

    func newSectionSnapshot() -> NSDiffableDataSourceSectionSnapshot<ItemIdentifierType> {
        NSDiffableDataSourceSectionSnapshot<ItemIdentifierType>()
    }
}
