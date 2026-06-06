import UIKit


// MARK: - AnyGroup

public struct AnyGroup<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: Group {

    let erased: any Group<SectionIdentifier, ItemIdentifier>


    // MARK: Group

    public var elementKinds: [String] {
        erased.elementKinds
    }

    public func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        erased.supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
    }

    public func makeLayoutGroup(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        erased.makeLayoutGroup(environment: environment)
    }


    // MARK: GroupItem

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        erased.makeLayoutGroupItem(defaultSize: defaultSize, environment: environment)
    }
}
