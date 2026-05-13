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


@available(iOS 15, *)
public extension CollectionViewLayoutStrategy {

    func makeDataSourceAndSetLayout(
        for collectionView: UICollectionView,
        snapshot: NSDiffableDataSourceSnapshot<SectionIdentifier, ItemIdentifier>? = nil,
        cellProvider: @escaping (IndexPath, ItemIdentifier) -> (CellFactory<ItemIdentifier>?)
    ) -> CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier> {
        "TODO:  Change return type to any CollectionViewTransactionableDiffableDataSource<SectionIdentifier, ItemIdentifier>"
        // # Configure data
        let dataSource = CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, item in
                let dataSource = collectionView.dataSource as? UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>
                let sectionIdentifier = dataSource?.sectionIdentifier(for: indexPath.section)
                guard let cell = makeCell(for: collectionView, itemIdentifier: item, in: sectionIdentifier!, at: indexPath, factoryProvider: cellProvider) else {
                    log.fault("Failed to create cell for item at '\(indexPath)' for \(collectionView)). Defaulting to an empty cell. ")
                    let empty = CellFactory<ItemIdentifier>(
                        cellClass: UICollectionViewCell.self,
                        reuseIdentifier: "\(#file):\(#line):\(#column)",
                        configuration: { _, _, _ in }
                    )
                    return empty.makeCell(for: collectionView, indexPath: indexPath, item: item)!
                }
                return cell
            }
        )
        dataSource.supplementaryViewProvider = { [unowned dataSource] collectionView, elementKind, indexPath in
            self.makeSupplementaryView(ofKind: elementKind, for: collectionView, at: indexPath, dataSource: dataSource)
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
        let layout = self.makeLayout(dataSource: dataSource)
        self.registerReusableViews(in: collectionView, layout: layout)
        collectionView.setCollectionViewLayout(layout, animated: false)

        return dataSource
    }
}
