import UIKit


public struct SectionHeader<SectionIdentifier: Hashable> {

    public typealias Handler<T> = (T, IndexPath, SectionIdentifier) -> Void

    static var elementKind: String { UICollectionView.elementKindSectionHeader }
    var elementKind: String { Self.elementKind }

    let dequeue: (UICollectionView, IndexPath, SectionIdentifier) -> UICollectionReusableView
    let configure: (UICollectionReusableView, IndexPath, SectionIdentifier) -> Void


    func asSupplementaryRegistration<ItemIdentifier>() -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier> {
        SupplementaryRegistration(
            dequeue: { (collectionView, indexPath, section: SectionIdentifier, item: ItemIdentifier?) in
                self.dequeue(collectionView, indexPath, section)
            },
            configure: { (view, indexPath, section: SectionIdentifier, item: ItemIdentifier?) in
                self.configure(view, indexPath, section)
            }
        )
    }
}


public extension SectionHeader {

    var asBoundarySupplement: BoundarySupplement<SectionIdentifier> {
        BoundarySupplement(
            dequeue: dequeue,
            configure: configure,
            layoutBoundarySupplementaryItemProvider: {
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
                    elementKind: elementKind,
                    alignment: .top
                )
            }
        )
    }
}


// MARK: - Inits

public extension SectionHeader {

    init<T: UICollectionReusableView>(
        viewType: T.Type? = nil,
        configuration: @escaping (T, SectionIdentifier) -> Void
    ) {
        let registration = UICollectionView.SupplementaryRegistration<T>( elementKind: Self.elementKind) { _, _, _ in }
        self.init(
            dequeue: { collectionView, indexPath, section in
                collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
            }, configure: { view, indexPath, section in
                configuration(view as! T, section)
            }
        )
    }

    init<T: UIView>(staticContent: @escaping () -> T) {
        let registration = UICollectionView.SupplementaryRegistration<ContentCell<T>>(elementKind: Self.elementKind) { _, _, _ in }
        self.init(
            dequeue: { collectionView, indexPath, section in
                collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
            },
            configure: { view, indexPath, section in
                let cell = view as! ContentCell<T>
                if cell.content == nil {
                    let content = staticContent()
                    cell.setContentView(content)
                }
            }
        )
    }
}


public extension SectionHeader {

    init(configuration: @escaping(_ configuration: inout UIListContentConfiguration, _ section: SectionIdentifier) -> Void) {
        self.init(viewType: UICollectionViewListCell.self, configuration: { cell, item in
            var contentConfiguration = (cell.contentConfiguration as? UIListContentConfiguration) ?? cell.defaultContentConfiguration()
            configuration(&contentConfiguration, item)
            cell.contentConfiguration = contentConfiguration
        })
    }

    init(title: String) {
        self.init(viewType: UICollectionViewListCell.self, configuration: { cell, item in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = title
            cell.contentConfiguration = configuration
        })
    }
}
