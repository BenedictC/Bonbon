import UIKit


public extension Group {

    func supplements(
        @ArrayBuilder<Supplement<SectionIdentifier, ItemIdentifier>>
        _ supplementsBuilder: () -> [Supplement<SectionIdentifier, ItemIdentifier>]
    ) -> SupplementedGroup<SectionIdentifier, ItemIdentifier> {
        let supplements = supplementsBuilder()
        return SupplementedGroup<SectionIdentifier, ItemIdentifier>(
            group: self,
            supplements: supplements
        )
    }
}


// MARK: - SupplementedGroup

@MainActor
public struct SupplementedGroup<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: Group {

    let group: any Group<SectionIdentifier, ItemIdentifier>
    let supplements: [Supplement<SectionIdentifier, ItemIdentifier>]

    init(group: some Group<SectionIdentifier, ItemIdentifier>, supplements: [Supplement<SectionIdentifier, ItemIdentifier>]) {
        self.group = group
        self.supplements = supplements
    }


    // MARK: GroupItem

    public var elementKinds: [String] {
        var elementKinds = Set<String>()
        elementKinds.formUnion(group.elementKinds)

        for supplement in supplements {
            elementKinds.insert(supplement.elementKind)
        }
        return Array(elementKinds)
    }

    public func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        let groupRegistration = group.supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
        if let groupRegistration {
            return groupRegistration
        }
        let matching = supplements.first { $0.elementKind == elementKind }
        return matching?.supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, sectionIdentifier: sectionIdentifier)

    }

    public func makeLayoutGroupItem(defaultSize: NSCollectionLayoutSize, environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutItem {
        makeLayoutGroup(environment: environment)
    }


    // MARK: Group

    public func makeLayoutGroup(environment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutGroup {
        let layout = group.makeLayoutGroup(environment: environment)
        let supplementaryItems = supplements.map { $0.makeLayoutSupplementaryItem(defaultSize: layout.layoutSize) }
        layout.supplementaryItems = supplementaryItems
        return layout
    }
}
