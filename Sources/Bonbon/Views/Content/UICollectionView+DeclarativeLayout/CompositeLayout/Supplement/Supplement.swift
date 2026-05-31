import UIKit


@MainActor
public struct Supplement<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    // MARK: Types

    public typealias LayoutSupplementaryItemProvider = (NSCollectionLayoutSize) -> NSCollectionLayoutSupplementaryItem
    public typealias Handler = (UICollectionView, String, IndexPath, ItemIdentifier) -> UICollectionReusableView?


    // MARK: Properties

    let elementKind: String
    private let layoutSupplementaryItemProvider: LayoutSupplementaryItemProvider
    private let dequeue: (UICollectionView, IndexPath, SectionIdentifier, ItemIdentifier?) -> UICollectionReusableView
    private let configure: (UICollectionReusableView, IndexPath, SectionIdentifier, ItemIdentifier?) -> Void


    // MARK: Instance life cycle

    init(
        elementKind: String,
        layoutSupplementaryItemProvider: @escaping LayoutSupplementaryItemProvider,
        dequeue: @escaping (UICollectionView, IndexPath, SectionIdentifier, ItemIdentifier?) -> UICollectionReusableView,
        configure: @escaping (UICollectionReusableView, IndexPath, SectionIdentifier, ItemIdentifier?) -> Void,
    ) {
        self.elementKind = elementKind
        self.layoutSupplementaryItemProvider = layoutSupplementaryItemProvider
        self.dequeue = dequeue
        self.configure = configure
    }


    // MARK: Layout creation

    func makeLayoutSupplementaryItem(defaultSize: NSCollectionLayoutSize) -> NSCollectionLayoutSupplementaryItem {
        layoutSupplementaryItemProvider(defaultSize)
    }

    func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        SupplementaryRegistration(
            dequeue: dequeue,
            configure: configure
        )
    }
}


// MARK: - ReusableViewConfigurable

public extension Supplement {

    init<V: UICollectionReusableView>(
        _ viewClass: V.Type,
        size: NSCollectionLayoutSize? = nil,
        containerAnchor: NSCollectionLayoutAnchor,
        itemAnchor: NSCollectionLayoutAnchor? = nil,
        configuration: @escaping (V, IndexPath, SectionIdentifier, ItemIdentifier?) -> Void = { _, _, _, _ in }
    ) {
        let elementKind = UniqueIdentifier("SupplementaryView").value
        let registration = UICollectionView.SupplementaryRegistration<V>(elementKind: elementKind) { view, IndexPath, section in }

        self.init(
            elementKind: elementKind,
            layoutSupplementaryItemProvider: { defaultSize in
                let size = size ?? defaultSize
                if let itemAnchor {
                    return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor, itemAnchor: itemAnchor)
                } else {
                    return NSCollectionLayoutSupplementaryItem(layoutSize: size, elementKind: elementKind, containerAnchor: containerAnchor)
                }
            },
            dequeue: { collectionView, indexPath, _, _ in
                let view = collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
                return view
            },
            configure: { view, indexPath, sectionIdentifier, itemIdentifier in
               configuration(view as! V, indexPath, sectionIdentifier, itemIdentifier)
            }
        )
    }
}
