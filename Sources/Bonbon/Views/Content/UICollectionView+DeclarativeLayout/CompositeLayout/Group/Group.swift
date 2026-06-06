import UIKit


// MARK: - Core types

@MainActor
public protocol Group<SectionIdentifier, ItemIdentifier>: GroupItem where SectionIdentifier: Hashable, ItemIdentifier: Hashable {

    typealias LayoutGroupProvider = (_ environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup

    var elementKinds: [String] { get }

    func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>?

    func makeLayoutGroup(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup
}


// MARK: - GroupItem default implementation

extension Group {

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        makeLayoutGroup(environment: environment)
    }
}


// MARK: - Type erasure

extension Group {

    func eraseToAnyGroup() -> AnyGroup<SectionIdentifier, ItemIdentifier> {
        AnyGroup(erased: self)
    }
}
