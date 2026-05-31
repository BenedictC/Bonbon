import UIKit

@MainActor
public protocol AxisGroup: Group {

    typealias LayoutGroupItemsProvider = (any NSCollectionLayoutEnvironment) -> [NSCollectionLayoutItem]

    static var axis: AxisGroupAxis { get }
    var groupSize: NSCollectionLayoutSize? { get }
    var items: [AnyGroupItem<SectionIdentifier, ItemIdentifier>] { get }
    var layoutGroupItemsProvider: LayoutGroupItemsProvider { get }

    init(
        groupSize: NSCollectionLayoutSize?,
        items: [AnyGroupItem<SectionIdentifier, ItemIdentifier>],
        layoutGroupItemsProvider: @escaping LayoutGroupItemsProvider
    )
}


public enum AxisGroupAxis {
    case vertical, horizontal
}


extension AxisGroup {

    internal static func cellLayoutSize(forItemCount itemCount: Int, axis: AxisGroupAxis) -> NSCollectionLayoutSize {
        let fraction = 1.0 / Double(itemCount)
        return switch axis {
        case .vertical:
            NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(fraction))
        case .horizontal:
            NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: .fractionalHeight(1))
        }
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
        let groupSize = self.groupSize ?? Self.defaultGroupSize
        let subItems = self.layoutGroupItemsProvider(environment)
        switch Self.axis {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: subItems)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: subItems)
        }
    }


    // MARK: GroupItem

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        let size = self.groupSize ?? defaultSize
        let subItems = self.items.map({ $0.makeLayoutGroupItem(defaultSize: size, environment: environment) })
        switch Self.axis {
        case .vertical:
            return NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: subItems)
        case .horizontal:
            return NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: subItems)
        }
    }
}


public extension AxisGroup {

    init(
        size groupSize: NSCollectionLayoutSize? = nil,
        numberOfItems: Int? = nil,
        @GroupItemsBuilder<SectionIdentifier, ItemIdentifier>
        items itemsBuilder: () -> [AnyGroupItem<SectionIdentifier, ItemIdentifier>]
    ) {
        let items = itemsBuilder()
        let itemsCount = numberOfItems ?? items.count
        let axis = Self.axis
        self.init(
            groupSize: groupSize,
            items: items,
            layoutGroupItemsProvider: { environment in
                let itemSize = Self.cellLayoutSize(forItemCount: itemsCount, axis: axis)
                return items.map { $0.makeLayoutGroupItem(defaultSize: itemSize, environment: environment) }
            }
        )
    }

    init(
        minimumColumnWidth: CGFloat,
        @GroupItemsBuilder<SectionIdentifier, ItemIdentifier>
        items itemsBuilder: () -> [AnyGroupItem<SectionIdentifier, ItemIdentifier>]
    ) {
        let items = itemsBuilder()
        let axis = Self.axis
        self.init(groupSize: nil, items: items) { environment in
            let repetitions = max(1, Int((environment.container.effectiveContentSize.width / minimumColumnWidth).nextDown))
            let itemSize = Self.cellLayoutSize(forItemCount: repetitions, axis: axis)
            return items.map { $0.makeLayoutGroupItem(defaultSize: itemSize, environment: environment) }
        }
    }
}
