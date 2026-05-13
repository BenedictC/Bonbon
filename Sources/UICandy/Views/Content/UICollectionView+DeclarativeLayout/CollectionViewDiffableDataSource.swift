import UIKit


public typealias CollectionViewDiffableDataSourceIndexElement = (title: String, indexPath: IndexPath)

public enum CollectionViewDiffableDataSourceUpdateMode {
    case animated
    case unanimated
    @available(iOS 15, *)
    case reload
}


@available(iOS 14, *)
public final class CollectionViewDiffableDataSource<SectionIdentifierType: Hashable, ItemIdentifierType: Hashable>: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType> {

    // MARK: Types

    public typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>
    public typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemIdentifierType>
    public typealias IndexElement = CollectionViewDiffableDataSourceIndexElement
    public typealias IndexElementsProvider = (NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>) -> [IndexElement]


    // MARK: Properties

    public var indexElementsProvider: IndexElementsProvider? {
        didSet { collectionView?.reloadData() }
    }

    private weak var collectionView: UICollectionView?
    private var cachedIndexElements: [IndexElement]?
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


// MARK: - Transaction Queue

public enum CollectionViewDiffableDataSourceQueueMode {
    case append, clear
}



@available(iOS 14, *)
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

@available(iOS 14, *)
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

    @available(iOS 14, *)
    func newSectionSnapshot() -> NSDiffableDataSourceSectionSnapshot<ItemIdentifierType> {
        NSDiffableDataSourceSectionSnapshot<ItemIdentifierType>()
    }
}
