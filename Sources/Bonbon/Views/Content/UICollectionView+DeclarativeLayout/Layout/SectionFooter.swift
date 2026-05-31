import UIKit


public struct SectionFooter<SectionIdentifier: Hashable> {

    public typealias Handler<T> = (T, IndexPath, SectionIdentifier) -> Void

    static var elementKind: String { UICollectionView.elementKindSectionFooter }
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


// MARK: - Inits

public extension SectionFooter {

    init<T: UICollectionReusableView>(
        viewType: T.Type? = nil,
        configuration: @escaping (T, SectionIdentifier) -> Void
    ) {
        let registration = UICollectionView.SupplementaryRegistration<T>( elementKind: Self.elementKind) { _, _, _ in }
        self.init(
            dequeue: { collectionView, indexPath, section in
                collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
            },
            configure: { view, indexPath, section in
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


@available(*, deprecated, message: "TODO: Tidy these")
public extension SectionFooter {

    init(title: @escaping(SectionIdentifier) -> String) {
        self.init(viewType: UICollectionViewListCell.self, configuration: { cell, item in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = title(item)
            cell.contentConfiguration = configuration
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
