import UIKit


@MainActor
public struct LayoutFooter {

    // MARK: Types

    public typealias SupplementRegistrar = (UICollectionView) -> Void
    public typealias SupplementProvider = (String, UICollectionView, IndexPath, Void) -> UICollectionReusableView?


    // MARK: Properties

    static let elementKind = UniqueIdentifier("LayoutFooter").value
    var elementKind: String { Self.elementKind }
    let dequeue: (UICollectionView, IndexPath) -> UICollectionReusableView
    let configure: (UICollectionReusableView) -> Void


    // MARK: Instance life cycle

    public init<T: UICollectionReusableView>(
        configure: @escaping (T) -> Void
    ) {
        let registration = UICollectionView.SupplementaryRegistration<T>(elementKind: Self.elementKind, handler: { (_: T, _, _) in })
        self.dequeue = { collectionView, indexPath in
            let view = collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
            configure(view)
            return view
        }
        self.configure = { view in
            configure(view as! T)
        }
    }


    // MARK:  BoundarySupplement

    public func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(44)
        )
        let layoutItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: elementKind,
            alignment: .bottom,
            absoluteOffset: .zero
        )
        return layoutItem
    }

    public func asBoundarySupplement() -> BoundarySupplement<Void> {
        BoundarySupplement(
            dequeue: { (collectionView, indexPath, _) in dequeue(collectionView, indexPath) },
            configure: { view, _, _ in configure(view) },
            layoutBoundarySupplementaryItemProvider: makeLayoutBoundarySupplementaryItem,
        )
    }
}


// MARK: - Inits

public extension LayoutFooter {

    init<Content: UIView>(
        staticContent contentBuilder: @escaping () -> Content
    ) {
        self.init(configure: { (cell: ContentCell<Content>) in
            if cell.content == nil {
                let content = contentBuilder()
                cell.setContentView(content)
            }
        })
    }
}
