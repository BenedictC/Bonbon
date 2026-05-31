import UIKit


// MARK: - CollectionViewLayoutStrategy

@MainActor
public protocol CollectionViewLayoutStrategy<SectionIdentifier, ItemIdentifier> {

    associatedtype SectionIdentifier: Hashable
    associatedtype ItemIdentifier: Hashable
    typealias DiffableDataSource = CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>

    var behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemIdentifier> { get }

    func makeLayout(dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>) -> UICollectionViewLayout

    func registerDecorationViews(in collectionView: UICollectionView, layout: UICollectionViewLayout)
    var elementKinds: [String] { get }
    func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, dataSource: DiffableDataSource) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>
}


// MARK: - CollectionViewLayoutBehaviors

public struct CollectionViewLayoutBehaviors<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    public typealias Snapshot = NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>
    public typealias DiffableDataSource = CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>
    public typealias IndexElement = DiffableDataSource.IndexElement
    public typealias IndexElementsProvider = DiffableDataSource.IndexElementsProvider

    public let indexElementsProvider: IndexElementsProvider?
    public let reorderHandlers: DiffableDataSource.ReorderingHandlers?
    public let sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>?

    public init(
        indexElementsProvider: IndexElementsProvider?,
        reorderHandlers: DiffableDataSource.ReorderingHandlers?,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>?
    ) {
        self.indexElementsProvider = indexElementsProvider
        self.reorderHandlers = reorderHandlers
        self.sectionSnapshotHandlers = sectionSnapshotHandlers
    }
}
