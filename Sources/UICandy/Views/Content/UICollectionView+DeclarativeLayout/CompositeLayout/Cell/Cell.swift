import UIKit

@MainActor
public struct Cell<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: GroupItem {

    // MARK: Types

    public typealias LayoutGroupItemProvider = (_ size: NSCollectionLayoutSize, _ environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem
    public typealias Predicate = (_ indexPath: IndexPath, _ item: ItemIdentifier) -> Bool // Used by factories


    // MARK: Properties

    let layoutGroupItemProvider: LayoutGroupItemProvider


    // MARK: Instance life cycle

    @MainActor
    public init(
        layoutGroupItemProvider: LayoutGroupItemProvider? = nil // It would be nicer to have a default argument but the compiler thinks the value breaks isolation despite everything being @MainActor
    ) {
        self.layoutGroupItemProvider = layoutGroupItemProvider ?? Self.makeLayoutGroupItemProvider()
    }


    // MARK: Default values

    public static func makeLayoutGroupItemProvider(
        size preferredSize: NSCollectionLayoutSize? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil
    ) -> LayoutGroupItemProvider {
        return { defaultSize, environment in
            let size = preferredSize ?? defaultSize
            let item = NSCollectionLayoutItem(layoutSize: size, supplementaryItems: [])
            if let edgeSpacing {
                item.edgeSpacing = edgeSpacing
            }
            if let contentInsets {
                item.contentInsets = contentInsets
            }
            return item
        }
    }


    // MARK: GroupItem

    public var elementKinds: [String] { [] }

    public func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        nil
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        layoutGroupItemProvider(defaultSize, environment)
    }
}
