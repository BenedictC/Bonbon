import UIKit


public extension UICollectionView {

    convenience init(
        collectionViewLayout: UICollectionViewLayout = UICollectionViewLayout(),
        delegate: UICollectionViewDelegate?
    ) {
        self.init(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.delegate = delegate
    }
}


public extension CollectionViewLayoutStrategy {

    func makeDataSourceAndSetLayout(
        for collectionView: UICollectionView,
        snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>? = nil,
        cellRegistrations: [Any] = [],
        cellProvider: @escaping UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>.CellProvider
    ) -> CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> {
        // # Configure data
        let dataSource = CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>(
            collectionView: collectionView,
            cellProvider: cellProvider
        )
        // # Create layout
        let layout = self.makeLayout(dataSource: dataSource)
        let elementKinds = self.registerReusableViews(in: collectionView, layout: layout)

        // # Configure dataSource
        dataSource.setSupplementaryElementKinds(
            elementKinds,
            supplementaryRegistrationProvider: { [unowned dataSource] elementKind, indexPath in
                supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, dataSource: dataSource)
            }
        )
        dataSource.supplementaryViewProvider = { [unowned dataSource] collectionView, elementKind, indexPath in
            let registration = supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, dataSource: dataSource)
            let snapshot = dataSource.snapshot()
            let section = snapshot.sectionIdentifiers[indexPath.section]
            let itemsInSection = snapshot.itemIdentifiers(inSection: section)
            let item = indexPath.item < itemsInSection.count ? itemsInSection[indexPath.item] : nil
            return registration.dequeueSupplementary(collectionView: collectionView, indexPath: indexPath, section: section, item: item)
        }
        dataSource.indexElementsProvider = self.behaviors.indexElementsProvider
        if let reorderHandlers = self.behaviors.reorderHandlers {
            dataSource.reorderingHandlers = reorderHandlers
        }
        if let sectionSnapshotHandlers = self.behaviors.sectionSnapshotHandlers {
            dataSource.sectionSnapshotHandlers = sectionSnapshotHandlers
        }
        if let snapshot {
            dataSource.apply(snapshot, animatingDifferences: false)
        }

        // # Configure view
        collectionView.setCollectionViewLayout(layout, animated: false)

        return dataSource
    }
}
