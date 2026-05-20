import UIKit


// MARK: - CompositeLayout

@MainActor
public struct CompositeLayout<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: CollectionViewLayoutStrategy {

    // MARK: Properties

    public let behaviors: CollectionViewLayoutBehaviors<SectionIdentifier, ItemIdentifier>
    let background: LayoutBackground?
    let boundarySupplements: [BoundarySupplement<Void>]
    let sections: [CompositeSection<SectionIdentifier, ItemIdentifier>]


    // MARK: CollectionViewLayoutStrategy

    public func registerReusableViews(in collectionView: UICollectionView, layout: UICollectionViewLayout) -> [String] {
        if let background = self.background {
            collectionView.backgroundView = background.view
        }
        var elementKinds = Set<String>()

        for boundarySupplement in boundarySupplements {
            elementKinds.insert(boundarySupplement.elementKind)
        }
        for section in self.sections {
            elementKinds.formUnion(section.elementKinds)
        }
        return Array(elementKinds)
    }

    public func makeLayout(dataSource: UICollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>) -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        configuration.boundarySupplementaryItems = boundarySupplements.map { $0.makeLayoutBoundarySupplementaryItem() }

        return UICollectionViewCompositionalLayout(
            sectionProvider: { [weak dataSource] sectionIndex, environment in
                guard let dataSource else {
                    preconditionFailure("DataSource is no longer available.")
                }
                guard let sectionIdentifier = dataSource.sectionIdentifier(forSectionAtIndex: sectionIndex) else {
                    preconditionFailure("Invalid section index")
                }
                let section = self.makeSection(for: sectionIdentifier)
                return section.makeCompositionalLayoutSection(environment: environment)
            },
            configuration: configuration)
    }

    public func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, dataSource: CollectionViewDiffableDataSource<SectionIdentifier, ItemIdentifier>) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier> {
        let matchingBoundarySupplement = boundarySupplements.first {  $0.elementKind == elementKind }
        if let matchingBoundarySupplement {
            return matchingBoundarySupplement.asSupplementaryRegistration()
        }

        let snapshot = dataSource.snapshot()
        let sectionIDs = snapshot.sectionIdentifiers
        let sectionID = sectionIDs[indexPath.section]
        let section = makeSection(for: sectionID)
        if let registration = section.supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, sectionIdentifier: sectionID) {
            return registration
        }
        "TODO: is fatalError correct/most appropriate behaviour?"
        fatalError()
    }


    private func makeSection(for sectionIdentifier: SectionIdentifier) -> CompositeSection<SectionIdentifier, ItemIdentifier> {
        // Check sections with predicates for a match
        if let section = sections.first(where: { $0.predicate(sectionIdentifier) }) {
            return section
        }
        preconditionFailure("No sections to represent sectionIdentifier '\(sectionIdentifier)'.")
    }
}


// MARK: - Initializer

public extension CompositeLayout {

    init(
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>? = nil,
        background: LayoutBackground? = nil,
        header: LayoutHeader? = nil,
        footer: LayoutFooter? = nil,
        @ArrayBuilder<CompositeSection<SectionIdentifier, ItemIdentifier>>
        sections: () -> [CompositeSection<SectionIdentifier, ItemIdentifier>]
    ) {
        let boundarySupplements = [
            header?.asBoundarySupplement(),
            footer?.asBoundarySupplement()
        ].compactMap { $0 }

        self = Self(
            behaviors: CollectionViewLayoutBehaviors(
                indexElementsProvider: indexElementsProvider,
                reorderHandlers: reorderHandlers,
                sectionSnapshotHandlers: sectionSnapshotHandlers
            ),
            background: background,
            boundarySupplements: boundarySupplements,
            sections: sections()
        )
    }

    init(
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>? = nil,
        background: LayoutBackground? = nil,
        @ArrayBuilder<LayoutBoundarySupplement>
        boundarySupplements: () -> [LayoutBoundarySupplement],
        @ArrayBuilder<CompositeSection<SectionIdentifier, ItemIdentifier>>
        sections: () -> [CompositeSection<SectionIdentifier, ItemIdentifier>]
    ) {
        self = Self(
            behaviors: CollectionViewLayoutBehaviors(
                indexElementsProvider: indexElementsProvider,
                reorderHandlers: reorderHandlers,
                sectionSnapshotHandlers: sectionSnapshotHandlers
            ),
            background: background,
            boundarySupplements: boundarySupplements(),
            sections: sections()
        )
    }
}
