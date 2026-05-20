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

    public func registerReusableViews(in collectionView: UICollectionView) -> [String] {
        var elementKinds = Set<String>()
        for item in groupItems {
            let elementKind = item.registerReusableViews(in: collectionView)
            elementKinds.formUnion(elementKind)
        }
        return Array(elementKinds)
    }

    public func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        "TODO: "
        fatalError()
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
