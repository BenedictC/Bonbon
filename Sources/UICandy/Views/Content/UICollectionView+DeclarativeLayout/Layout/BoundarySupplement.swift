import UIKit


public struct BoundarySupplement<Value> {

    // MARK: Types

    public typealias LayoutBoundarySupplementaryItemProvider = () -> NSCollectionLayoutBoundarySupplementaryItem

    public typealias Handler<T> = (T, IndexPath, Value) -> Void


    // MARK: Properties

    public var elementKind: String { makeLayoutBoundarySupplementaryItem().elementKind }

    private let dequeue: (UICollectionView, IndexPath, Value) -> UICollectionReusableView
    private let configure: (UICollectionReusableView, IndexPath, Value) -> Void
    private let layoutBoundarySupplementaryItemProvider: LayoutBoundarySupplementaryItemProvider

    
    // MARK: Instance life cycle

    init(
        dequeue: @escaping (UICollectionView, IndexPath, Value) -> UICollectionReusableView,
        configure: @escaping (UICollectionReusableView, IndexPath, Value) -> Void,
        layoutBoundarySupplementaryItemProvider: @escaping LayoutBoundarySupplementaryItemProvider,
    ) {
        self.dequeue = dequeue
        self.configure = configure
        self.layoutBoundarySupplementaryItemProvider = layoutBoundarySupplementaryItemProvider
    }

    init<T: UICollectionReusableView>(
        layoutBoundarySupplementaryItemProvider: @escaping LayoutBoundarySupplementaryItemProvider,
        handler: @escaping Handler<T>
    ) {
        let elementKind = layoutBoundarySupplementaryItemProvider().elementKind
        self.layoutBoundarySupplementaryItemProvider = layoutBoundarySupplementaryItemProvider
        let registration = UICollectionView.SupplementaryRegistration<T>(elementKind: elementKind, handler: { _, _, _ in })
        self.dequeue = { collectionView, indexPath, value in
            let cell = collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
            handler(cell, indexPath, value)
            return cell
        }
        self.configure = { view, indexPath, value in
            handler(view as! T, indexPath, value)
        }
    }


    // MARK: Layout creation

    func makeLayoutBoundarySupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        layoutBoundarySupplementaryItemProvider()
    }


    // MARK: Registration creation

    public func asSupplementaryRegistration<Item>() -> SupplementaryRegistration<Value, Item> {
        SupplementaryRegistration(
            dequeue: {collectionView, indexPath, section, _ in
                self.dequeue(collectionView, indexPath, section)
            },
            configure: { cell, indexPath, section, _ in
                self.configure(cell, indexPath, section)
            }
        )
    }
}


extension BoundarySupplement where Value == Void {

    public func asSupplementaryRegistration<Section, Item>() -> SupplementaryRegistration<Section, Item> {
        SupplementaryRegistration(
            dequeue: {collectionView, indexPath, _, _ in
                self.dequeue(collectionView, indexPath, ())
            },
            configure: { cell, indexPath, _, _ in
                self.configure(cell, indexPath, ())
            }
        )
    }
}



// MARK: Factories

//public extension BoundarySupplement {
//
//    init<ViewType: UICollectionReusableView>(
//        viewType: ViewType.Type,
//        size: NSCollectionLayoutSize,
//        containerAnchor: NSCollectionLayoutAnchor,
//        itemAnchor: NSCollectionLayoutAnchor?,
//        extendsBoundary: Bool?,
//        pinToVisibleBounds: Bool?,
//        zIndex: Int?,
//        configuration: @escaping (ViewType, Value) -> Void
//    ) {
//        let elementKind = UniqueIdentifier("\(Self.self) elementKind").value
//        let reuseIdentifier = UniqueIdentifier("\(Self.self) reuseIdentifier").value
//
//        self.init(
//            layoutBoundarySupplementaryItemProvider: {
//                let item = NSCollectionLayoutBoundarySupplementaryItem(
//                    layoutSize: size,
//                    elementKind: elementKind,
//                    containerAnchor: containerAnchor,
//                    itemAnchor: itemAnchor ?? containerAnchor
//                )
//                extendsBoundary.flatMap { item.extendsBoundary = $0 }
//                pinToVisibleBounds.flatMap { item.pinToVisibleBounds = $0 }
//                zIndex.flatMap { item.zIndex = $0 }
//                return item
//            },
//            handler: { view, collectionView, indexPath, value in
//                configuration(view, value)
//                return view
//            }
//        )
//    }
//
//    init<ViewType: CollectionReusableView>(
//        viewType: ViewType.Type,
//        size: NSCollectionLayoutSize,
//        containerAnchor: NSCollectionLayoutAnchor,
//        itemAnchor: NSCollectionLayoutAnchor?,
//        extendsBoundary: Bool?,
//        pinToVisibleBounds: Bool?,
//        zIndex: Int?
//    ) where ViewType.Item == Value {
//        let elementKind = UniqueIdentifier("\(Self.self) elementKind").value
//        let reuseIdentifier = UniqueIdentifier("\(Self.self) reuseIdentifier").value
//
//        self.init(
//            supplementRegistrar: { collectionView in
//                collectionView.register(ViewType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
//            },
//            layoutBoundarySupplementaryItemProvider: {
//                let item = NSCollectionLayoutBoundarySupplementaryItem(
//                    layoutSize: size,
//                    elementKind: elementKind,
//                    containerAnchor: containerAnchor,
//                    itemAnchor: itemAnchor ?? containerAnchor
//                )
//                extendsBoundary.flatMap { item.extendsBoundary = $0 }
//                pinToVisibleBounds.flatMap { item.pinToVisibleBounds = $0 }
//                zIndex.flatMap { item.zIndex = $0 }
//                return item
//            },
//            supplementProvider: {  _, collectionView, indexPath, value in
//                let view = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! ViewType
//                view.item = value
//                return view
//            }
//        )
//    }
//}
//
//
//// MARK: - Content
//
//public extension BoundarySupplement {
//
//    init<Content: UIView>(
//        size: NSCollectionLayoutSize,
//        containerAnchor: NSCollectionLayoutAnchor,
//        itemAnchor: NSCollectionLayoutAnchor?,
//        extendsBoundary: Bool?,
//        pinToVisibleBounds: Bool?,
//        zIndex: Int?,
//        contentBuilder: @escaping () -> Content
//    ) {
//        typealias ViewType = StaticContentReusableCollectionView<Content>
//        let elementKind = UniqueIdentifier("\(Self.self) elementKind").value
//        let reuseIdentifier = UniqueIdentifier("\(Self.self) reuseIdentifier").value
//        self.init(
//            supplementRegistrar: { collectionView in
//                collectionView.register(ViewType.self, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: reuseIdentifier)
//            },
//            layoutBoundarySupplementaryItemProvider: {
//                let item = NSCollectionLayoutBoundarySupplementaryItem(
//                    layoutSize: size,
//                    elementKind: elementKind,
//                    containerAnchor: containerAnchor,
//                    itemAnchor: itemAnchor ?? containerAnchor
//                )
//                extendsBoundary.flatMap { item.extendsBoundary = $0 }
//                pinToVisibleBounds.flatMap { item.pinToVisibleBounds = $0 }
//                zIndex.flatMap { item.zIndex = $0 }
//                return item
//            },
//            supplementProvider: { _, collectionView, indexPath, value in
//                let cell = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! ViewType
//                cell.setContentIfNeeded(contentBuilder: { _ in contentBuilder() })
//                return cell
//            }
//        )
//    }
//}
