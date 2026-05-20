import UIKit


// MARK: - Layout

public extension ListLayout {

    typealias ListSectionWithCollapsableHeader = ListSection<SectionIdentifier, ItemIdentifier, ItemIdentifier>

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration = LayoutConfiguration(builder: { _ in }),
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>? = nil,
        background: LayoutBackground? = nil,
        header: LayoutHeader? = nil,
        footer: LayoutFooter? = nil,
        @ArrayBuilder<ListSectionWithCollapsableHeader>
        sectionsWithCollapsableHeader sections: () -> [ListSectionWithCollapsableHeader]
    ) {
        let boundarySupplements = [
            header?.asBoundarySupplement(),
            footer?.asBoundarySupplement()
        ].compactMap { $0 }
        let components = ListLayoutComponents(
            configuration: configuration,
            background: background,
            boundarySupplements: boundarySupplements,
            sections: sections().map { $0.eraseToAnyListSection() }
        )
        let behaviors = CollectionViewLayoutBehaviors(
            indexElementsProvider: indexElementsProvider,
            reorderHandlers: reorderHandlers,
            sectionSnapshotHandlers: sectionSnapshotHandlers
        )

        self.init(appearance: appearance, components: components, behaviors: behaviors)
    }

    init(
        appearance: UICollectionLayoutListConfiguration.Appearance,
        configuration: LayoutConfiguration = LayoutConfiguration(builder: { _ in }),
        indexElementsProvider: DiffableDataSource.IndexElementsProvider? = nil,
        reorderHandlers: DiffableDataSource.ReorderingHandlers? = nil,
        sectionSnapshotHandlers: DiffableDataSource.SectionSnapshotHandlers<ItemIdentifier>? = nil,
        background: LayoutBackground? = nil,
        @ArrayBuilder<LayoutBoundarySupplement>
        boundarySupplements: () -> [LayoutBoundarySupplement],
        footer: LayoutFooter? = nil,
        @ArrayBuilder<ListSectionWithCollapsableHeader>
        sectionsWithCollapsableHeader sections: () -> [ListSectionWithCollapsableHeader]
    ) {
        let components = ListLayoutComponents(
            configuration: configuration,
            background: background,
            boundarySupplements: boundarySupplements(),
            sections: sections().map { $0.eraseToAnyListSection() }
        )
        let behaviors = CollectionViewLayoutBehaviors(
            indexElementsProvider: indexElementsProvider,
            reorderHandlers: reorderHandlers,
            sectionSnapshotHandlers: sectionSnapshotHandlers
        )

        self.init(appearance: appearance, components: components, behaviors: behaviors)
    }
}


// MARK: - ListSection

public extension ListSection where HeaderType == ItemIdentifier {

    init(
        predicate: @escaping ((SectionIdentifier) -> Bool) = { _ in true },
        footer: SectionFooter<SectionIdentifier>? = nil,
    ) {
        self = Self(
            predicate: predicate,
            header: .collapsable,
            footer: footer
        )
    }

    init(
        identifier: SectionIdentifier,
        footer: SectionFooter<SectionIdentifier>? = nil,
    ) {
        self = Self(
            predicate: { $0 == identifier },
            header: .collapsable,
            footer: footer
        )
    }
}


public extension ListSection where HeaderType == ItemIdentifier {

    init(
        predicate: @escaping ((SectionIdentifier) -> Bool) = { _ in true },
        footer: () -> SectionFooter<SectionIdentifier>,
    ) {
        self = Self(
            predicate: predicate,
            header: .collapsable,
            footer: footer()
        )
    }

    init(
        identifiers: SectionIdentifier...,
        footer: () -> SectionFooter<SectionIdentifier>,
    ) {
        self = Self(
            predicate: { identifiers.contains($0) },
            header: .collapsable,
            footer: footer()
        )
    }

    init(
        predicate: @escaping ((SectionIdentifier) -> Bool) = { _ in true },
    ) {
        self = Self(
            predicate: predicate,
            header: .collapsable,
            footer: nil
        )
    }

    init(
        identifiers: SectionIdentifier...,
    ) {
        self = Self(
            predicate: { identifiers.contains($0) },
            header: .collapsable,
            footer: nil
        )
    }
}
