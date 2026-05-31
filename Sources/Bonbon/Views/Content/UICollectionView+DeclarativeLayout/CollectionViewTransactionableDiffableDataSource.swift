import UIKit


@MainActor
public protocol CollectionViewTransactionableDiffableDataSource<SectionIdentifierType, ItemIdentifierType> {

    associatedtype SectionIdentifierType: Hashable
    associatedtype ItemIdentifierType: Hashable
    typealias TransactionContext = CollectionViewDiffableDataSourceTransactionContext<SectionIdentifierType, ItemIdentifierType>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>

    var supplementaryViewProvider: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>.SupplementaryViewProvider? { get set }
    var reorderingHandlers: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>.ReorderingHandlers { get set }
    var sectionSnapshotHandlers: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>.SectionSnapshotHandlers<ItemIdentifierType> { get set }


    func itemIdentifier(for indexPath: IndexPath) -> ItemIdentifierType?
    func indexPath(for itemIdentifier: ItemIdentifierType) -> IndexPath?
    func sectionIdentifier(for index: Int) -> SectionIdentifierType?
    func index(for sectionIdentifier: SectionIdentifierType) -> Int?

    func snapshot() -> Snapshot
    func snapshot(for section: SectionIdentifierType) -> NSDiffableDataSourceSectionSnapshot<ItemIdentifierType>

    func description() -> String

    func enqueue(transaction: @escaping (TransactionContext) async -> Void)
    @discardableResult
    func enqueue<T>(transaction: @escaping (TransactionContext) async -> T) async -> T

    func enqueue(withMode mode: CollectionViewDiffableDataSourceQueueMode, transaction: @escaping (TransactionContext) async -> Void)
    @discardableResult
    func enqueue<T>(withMode mode: CollectionViewDiffableDataSourceQueueMode, transaction: @escaping (TransactionContext) async -> T) async -> T

    func newSnapshot() -> Snapshot

    func reconfigureSupplementaryViews()
}


// MARK: - CollectionViewDiffableDataSource conformance

extension CollectionViewDiffableDataSource: CollectionViewTransactionableDiffableDataSource {

    public func enqueue(transaction: @escaping (TransactionContext) async -> Void) {
        enqueue(withMode: .append, transaction: transaction)
    }

    public func enqueue<T>(transaction: @escaping (TransactionContext) async -> T) async -> T {
        await enqueue(withMode: .append, transaction: transaction)
    }
}
