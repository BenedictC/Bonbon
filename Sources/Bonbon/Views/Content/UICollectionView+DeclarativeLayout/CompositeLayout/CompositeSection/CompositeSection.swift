import UIKit


// MARK: - CompositeSection

@MainActor
public struct CompositeSection<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    // MARK: Properties

    let predicate: ((SectionIdentifier) -> Bool)
    private let orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior?
    private let interGroupSpacing: CGFloat?
    private let contentInsets: NSDirectionalEdgeInsets?
    private let contentInsetsReference: UIContentInsetsReference?
    private let supplementaryContentInsetsReference: UIContentInsetsReference?
    private let visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?
    private let boundarySupplements: [BoundarySupplement<SectionIdentifier>]
    private let background: Background?
    private let group: any Group<SectionIdentifier, ItemIdentifier>


    // MARK: Instance life cycle
    
    init(
        predicate: @escaping ((SectionIdentifier) -> Bool),
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior?,
        interGroupSpacing: CGFloat?,
        contentInsets: NSDirectionalEdgeInsets?,
        contentInsetsReference: UIContentInsetsReference?,
        supplementaryContentInsetsReference: UIContentInsetsReference?,
        visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler?,
        background: Background?,
        boundarySupplements: [BoundarySupplement<SectionIdentifier>],
        group: any Group<SectionIdentifier, ItemIdentifier>
    ) {
        self.predicate = predicate
        self.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        self.interGroupSpacing = interGroupSpacing
        self.contentInsets = contentInsets
        self.contentInsetsReference = contentInsetsReference
        self.supplementaryContentInsetsReference = supplementaryContentInsetsReference
        self.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
        self.background = background
        self.boundarySupplements = boundarySupplements
        self.group = group
    }


    // MARK: View registration

    func registerDecorationViews(in layout: UICollectionViewLayout) {
        if let background {
            background.registerDecorationView(in: layout)
        }
    }

    var elementKinds: [String] {
        var elementKinds = Set<String>()
        if let background {
            elementKinds.insert(background.elementKind)
        }

        for boundarySupplement in boundarySupplements {
            elementKinds.insert(boundarySupplement.elementKind)
        }
        return Array(elementKinds)
    }

    func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        let matchingBoundarySupplement = boundarySupplements.first { $0.elementKind == elementKind }
        if let matchingBoundarySupplement {
            return matchingBoundarySupplement.asSupplementaryRegistration()
        }
        return group.supplementaryRegistration(for: collectionView, elementKind: elementKind, indexPath: indexPath, sectionIdentifier: sectionIdentifier)
    }


    // MARK: Layout creation

    func makeCompositionalLayoutSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let group = group.makeLayoutGroup(environment: environment)

        let section = NSCollectionLayoutSection(group: group)
        if let orthogonalScrollingBehavior {
            section.orthogonalScrollingBehavior = orthogonalScrollingBehavior
        }
        if let interGroupSpacing {
            section.interGroupSpacing = interGroupSpacing
        }
        if let contentInsets {
            section.contentInsets = contentInsets
        }
        if let contentInsetsReference {
            section.contentInsetsReference = contentInsetsReference
        }
        if #available(iOS 16.0, *) {
            if let supplementaryContentInsetsReference {
                section.supplementaryContentInsetsReference = supplementaryContentInsetsReference
            }
        }
        if let visibleItemsInvalidationHandler {
            section.visibleItemsInvalidationHandler = visibleItemsInvalidationHandler
        }

        let boundarySupplementaryItem = boundarySupplements
            .map { $0.makeLayoutBoundarySupplementaryItem() }

        section.boundarySupplementaryItems = boundarySupplementaryItem

        if let background {
            section.decorationItems = [background.makeLayoutDecorationItem()]
        }

        return section
    }

}


// MARK: - Factories

public extension CompositeSection {

    // with trailing closure
    init(
        predicate: @escaping ((SectionIdentifier) -> Bool) = { _ in true },
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        contentInsetsReference: UIContentInsetsReference? = nil,
        interGroupSpacing: CGFloat? = nil,
        visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler? = nil,
        supplementaryContentInsetsReference: UIContentInsetsReference? = nil,
        @ArrayBuilder<BoundarySupplement<SectionIdentifier>>
        boundarySupplements: () -> [BoundarySupplement<SectionIdentifier>] = { [] },
        background: Background? = nil,
        group: () -> some Group<SectionIdentifier, ItemIdentifier>
    ) {
        self = CompositeSection(
            predicate: predicate,
            orthogonalScrollingBehavior: orthogonalScrollingBehavior,
            interGroupSpacing: interGroupSpacing,
            contentInsets: contentInsets,
            contentInsetsReference: contentInsetsReference,
            supplementaryContentInsetsReference: supplementaryContentInsetsReference,
            visibleItemsInvalidationHandler: visibleItemsInvalidationHandler,
            background: background,
            boundarySupplements: boundarySupplements(),
            group: group().eraseToAnyGroup()
        )
    }
}


// MARK: With identifier

public extension CompositeSection {

    // with trailing closure
    init(
        identifier: SectionIdentifier,
        orthogonalScrollingBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior? = nil,
        contentInsets: NSDirectionalEdgeInsets? = nil,
        contentInsetsReference: UIContentInsetsReference? = nil,
        interGroupSpacing: CGFloat? = nil,
        visibleItemsInvalidationHandler: NSCollectionLayoutSectionVisibleItemsInvalidationHandler? = nil,
        supplementaryContentInsetsReference: UIContentInsetsReference? = nil,
        @ArrayBuilder<BoundarySupplement<SectionIdentifier>>
        boundarySupplements: () -> [BoundarySupplement<SectionIdentifier>] = { [] },
        background: Background? = nil,
        group: () -> some Group<SectionIdentifier, ItemIdentifier>
    ) {
        self.init(
            predicate: { $0 == identifier },
            orthogonalScrollingBehavior: orthogonalScrollingBehavior,
            interGroupSpacing: interGroupSpacing,
            contentInsets: contentInsets,
            contentInsetsReference: contentInsetsReference,
            supplementaryContentInsetsReference: supplementaryContentInsetsReference,
            visibleItemsInvalidationHandler: visibleItemsInvalidationHandler,
            background: background,
            boundarySupplements: boundarySupplements(),
            group: group()
        )
    }
}
