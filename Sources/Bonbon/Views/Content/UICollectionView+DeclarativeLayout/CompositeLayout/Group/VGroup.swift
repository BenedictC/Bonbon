import UIKit


@MainActor
public struct VGroup<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: Group {

    // MARK: Properties

    public let items: [AnyGroupItem<SectionIdentifier, ItemIdentifier>]
    public let layoutGroupProvider: LayoutGroupProvider


    // MARK: Instance life cycle

    public init(
        items: [AnyGroupItem<SectionIdentifier, ItemIdentifier>],
        layoutGroupProvider: @escaping LayoutGroupProvider
    ) {
        self.items = items
        self.layoutGroupProvider = layoutGroupProvider
    }


    // MARK: Group

    public var elementKinds: [String] {
        var elementKinds = Set<String>()
        for item in items {
            elementKinds.formUnion(item.elementKinds)
        }
        return Array(elementKinds)
    }

    public func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        for item in self.items {
            let registration = item.supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
            if let registration {
                return registration
            }
        }
        return nil
    }

    public func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        layoutGroupProvider(environment)
    }
}


// MARK: - Additions

public extension VGroup {

    internal static func itemLayoutSize(forItemCount itemCount: Int) -> NSCollectionLayoutSize {
        let fraction = 1.0 / Double(itemCount)
        return NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(fraction))
    }

    init(
        contentInsets: NSDirectionalEdgeInsets? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        interItemSpacing: NSCollectionLayoutSpacing? = nil,
        @GroupItemsBuilder<SectionIdentifier, ItemIdentifier>
        items itemsBuilder: () -> [AnyGroupItem<SectionIdentifier, ItemIdentifier>]

    ) {
        let items = itemsBuilder()
        self.init(
            items: items,
            layoutGroupProvider: { environment in
                // TODO: Should layoutSize be provided at init?
                let layoutSize = NSCollectionLayoutSize(widthDimension: .estimated(100), heightDimension: .fractionalHeight(1))
                let defaultItemSize = Self.itemLayoutSize(forItemCount: items.count)
                let subitemLayouts = items.map { $0.makeLayoutGroupItem(defaultSize: defaultItemSize, environment: environment) }
                let layoutGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: layoutSize,
                    subitems: subitemLayouts,
                )
                if let contentInsets {
                    layoutGroup.contentInsets = contentInsets
                }
                if let edgeSpacing {
                    layoutGroup.edgeSpacing = edgeSpacing
                }
                if let interItemSpacing {
                    layoutGroup.interItemSpacing = interItemSpacing
                }
                return layoutGroup
            }
        )
    }
}
