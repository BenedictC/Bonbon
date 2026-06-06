import UIKit


@MainActor
public struct CustomGroup<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: Group {

    let size: NSCollectionLayoutSize?
    let groupItems: [AnyGroupItem<SectionIdentifier, ItemIdentifier>]
    let layoutItemsProvider: NSCollectionLayoutGroupCustomItemProvider


    public init(
        size: NSCollectionLayoutSize? = nil,
        layoutItemsProvider: @escaping NSCollectionLayoutGroupCustomItemProvider,
        @GroupItemsBuilder<SectionIdentifier, ItemIdentifier>
        items: () -> [AnyGroupItem<SectionIdentifier, ItemIdentifier>]
    ) {
        self.size = size
        self.layoutItemsProvider = layoutItemsProvider
        self.groupItems = items()
    }


    // MARK: Group

    static var defaultGroupSize: NSCollectionLayoutSize {
        NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
    }
    
    public var elementKinds: [String] {
        var elementKinds = Set<String>()
        for item in groupItems {
            elementKinds.formUnion(item.elementKinds)
        }
        return Array(elementKinds)
    }

    public func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        let matching = groupItems.first { $0.elementKinds.contains(elementKind) }
        let registration = matching?.supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
        return registration
    }

    public func makeLayoutGroup(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        let size = self.size ?? Self.defaultGroupSize
        return NSCollectionLayoutGroup.custom(layoutSize: size, itemProvider: layoutItemsProvider)
    }


    // MARK: GroupItem

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        fatalError()
    }
}
