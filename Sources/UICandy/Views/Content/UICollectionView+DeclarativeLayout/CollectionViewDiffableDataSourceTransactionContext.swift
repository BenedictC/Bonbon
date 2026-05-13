import UIKit


@available(iOS 14, *)
@MainActor
public struct CollectionViewDiffableDataSourceTransactionContext<SectionIdentifierType: Hashable, ItemIdentifierType: Hashable> {

    // MARK: Types

    public typealias DataSource = CollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>


    // MARK: Properties

    internal let dataSource: DataSource
    internal let collectionView: UICollectionView


    // MARK: Accessors

    public func itemIdentifier(for indexPath: IndexPath) -> ItemIdentifierType? {
        dataSource.itemIdentifier(for: indexPath)
    }

    public func indexPath(for itemIdentifier: ItemIdentifierType) -> IndexPath? {
        dataSource.indexPath(for: itemIdentifier)
    }

    @available(iOS 15, *)
    public func sectionIdentifier(for index: Int) -> SectionIdentifierType? {
        dataSource.sectionIdentifier(for: index)
    }

    @available(iOS 15, *)
    public func index(for sectionIdentifier: SectionIdentifierType) -> Int? {
        dataSource.index(for: sectionIdentifier)
    }

    public func snapshot() -> NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType> {
        dataSource.snapshot()
    }

    public func snapshot(for section: SectionIdentifierType) -> NSDiffableDataSourceSectionSnapshot<ItemIdentifierType> {
        dataSource.snapshot(for: section)
    }

    public func description() -> String {
        dataSource.description()
    }


    // MARK: Snapshot updating

    public func apply(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>, animatingDifferences: Bool = true) async {
        await withCheckedContinuation { continuation in
            dataSource.apply(snapshot, animatingDifferences: animatingDifferences, completion: { continuation.resume() })
        }
    }

    @available(iOS 15, *)
    public func applySnapshotUsingReloadData(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>) async {
        await dataSource.applySnapshotUsingReloadData(snapshot)
    }

    public func apply(_ snapshot: NSDiffableDataSourceSectionSnapshot<ItemIdentifierType>, to section: SectionIdentifierType, animatingDifferences: Bool = true) async {
        await withCheckedContinuation { continuation in
            dataSource.apply(snapshot, to: section, animatingDifferences: animatingDifferences, completion: { continuation.resume() })
        }
    }
}

