import UIKit


// MARK: - Core types

@MainActor
public protocol Group<SectionIdentifier, ItemIdentifier>: GroupItem where SectionIdentifier: Hashable, ItemIdentifier: Hashable {

    func registerReusableViews(in collectionView: UICollectionView) -> [String]

    func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>?

    func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup
}


extension Group {

    static var defaultGroupSize: NSCollectionLayoutSize {
        NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
    }
}


// MARK: - AnyGroup

public struct AnyGroup<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: Group {

    let erased: any Group<SectionIdentifier, ItemIdentifier>
}


// MARK: Group

public extension AnyGroup {

    func registerReusableViews(in collectionView: UICollectionView) -> [String] {
        erased.registerReusableViews(in: collectionView)
    }

    func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        erased.supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
    }

    func makeLayoutGroup(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        erased.makeLayoutGroup(environment: environment)
    }
}


// MARK: - GroupItem

public extension AnyGroup {

    func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        erased.makeLayoutGroupItem(defaultSize: defaultSize, environment: environment)
    }
}


extension Group {

    func eraseToAnyGroup() -> AnyGroup<SectionIdentifier, ItemIdentifier> {
        AnyGroup(erased: self)
    }
}
