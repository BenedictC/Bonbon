import UIKit


@MainActor
public protocol GroupItem<SectionIdentifier, ItemIdentifier> {

    associatedtype SectionIdentifier: Hashable
    associatedtype ItemIdentifier: Hashable

    typealias LayoutGroupItemsProvider = (any NSCollectionLayoutEnvironment) -> [NSCollectionLayoutItem]

    var elementKinds: [String] { get }
    func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>?
    func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem
}


public struct SupplementedGroupItem<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: GroupItem {

    let groupItem: AnyGroupItem<SectionIdentifier, ItemIdentifier>
    let supplements: [Supplement<SectionIdentifier, ItemIdentifier>]


    public var elementKinds: [String] {
        var elementKinds = Set<String>()
        elementKinds.formUnion(groupItem.elementKinds)

        for supplement in supplements {
            elementKinds.insert(supplement.elementKind)
        }
        return Array(elementKinds)
    }

    public func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        let itemRegistration = groupItem.supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
        if let itemRegistration {
            return itemRegistration
        }
        let matching = supplements.first { $0.elementKind == elementKind }
        return matching?.supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        let initial = groupItem.makeLayoutGroupItem(defaultSize: defaultSize, environment: environment)
        let supplementaryItems = supplements.map { $0.makeLayoutSupplementaryItem(defaultSize: defaultSize) }
        let revised = NSCollectionLayoutItem(layoutSize: initial.layoutSize, supplementaryItems: supplementaryItems)
        revised.edgeSpacing = initial.edgeSpacing
        revised.contentInsets = initial.contentInsets
        return revised
    }
}


// MARK: AnyGroupItem

public struct AnyGroupItem<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: GroupItem {

    let erased: any GroupItem<SectionIdentifier, ItemIdentifier>

    public var elementKinds: [String] {
        erased.elementKinds
    }

    public func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        erased.supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        erased.makeLayoutGroupItem(defaultSize: defaultSize, environment: environment)
    }
}


public extension GroupItem {

    func eraseToAnyGroupItem() -> AnyGroupItem<SectionIdentifier, ItemIdentifier> {
        AnyGroupItem(erased: self)
    }
}
