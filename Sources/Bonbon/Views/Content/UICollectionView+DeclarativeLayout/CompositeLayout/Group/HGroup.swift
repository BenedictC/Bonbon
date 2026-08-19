import UIKit


@MainActor
public struct HGroup<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: Group {

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

public extension HGroup {

    static var defaultSize: NSCollectionLayoutSize { NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)) }

    internal static func itemLayoutSize(forItemCount itemCount: Int) -> NSCollectionLayoutSize {
        let fraction = 1.0 / Double(itemCount)
        return NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
    }


    init(
        size preferredSize: NSCollectionLayoutSize? = nil,
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
                // This should be a default parameter value but Swift concurrency prevents that. Seems like a compiler bug.
                let groupSize = preferredSize ?? Self.defaultSize
                let itemSize = Self.itemLayoutSize(forItemCount: items.count)
                let subitemLayouts = items.map { $0.makeLayoutGroupItem(defaultSize: itemSize, environment: environment) }
                let layoutGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
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


// MARK: - Specialized behaviour

public extension HGroup {

    init(
        contentInsets: NSDirectionalEdgeInsets? = nil,
        edgeSpacing: NSCollectionLayoutEdgeSpacing? = nil,
        interItemSpacing: NSCollectionLayoutSpacing? = nil,
        minimumColumnWidth: CGFloat,
        item itemBuilder: () -> any GroupItem<SectionIdentifier, ItemIdentifier>
    ) {
        let item = itemBuilder()
        self.init(
            items: [item.eraseToAnyGroupItem()],
            layoutGroupProvider: { environment in
                // TODO: Should layoutSize be provided at init?
                let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
                let preferredColumnCount = Int((environment.container.effectiveContentSize.width / minimumColumnWidth))
                let columnCount = max(1, preferredColumnCount)
                let defaultItemSize = Self.itemLayoutSize(forItemCount: columnCount)
                let itemLayout = item.makeLayoutGroupItem(defaultSize: defaultItemSize, environment: environment)

                let layoutGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: layoutSize,
                    repeatingSubitem: itemLayout,
                    count: columnCount
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
