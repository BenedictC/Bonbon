import UIKit


// MARK: - AnyListSection

@MainActor
public struct AnyListSection<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    // MARK: Types

    public typealias Cells = (_ indexPath: IndexPath, ItemIdentifier) -> (CellFactory<ItemIdentifier>?)

    public enum HeaderKind {
        case none
        case standard(SectionHeader<SectionIdentifier>)
        case collapsable(CellFactory<ItemIdentifier>)
    }


    // MARK: Properties

    let predicate: ((SectionIdentifier) -> Bool)
    let header: HeaderKind
    let footer: SectionFooter<SectionIdentifier>?

    init(predicate: @escaping (SectionIdentifier) -> Bool, header: HeaderKind, footer: SectionFooter<SectionIdentifier>?) {
        self.predicate = predicate
        self.header = header
        self.footer = footer
    }


    // MARK: Registration

    func registerViews(in collectionView: UICollectionView) {
        switch header {
        case .standard(let header):
            header.registerReusableViews(in: collectionView)
        case .collapsable(let cell):
            cell.registerCellClass(in: collectionView)
        case .none:
            break
        }
        footer?.registerReusableViews(in: collectionView)
    }


    // MARK: View creation

    func makeSupplementaryView(ofKind elementKind: String, for collectionView: UICollectionView, at indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> UICollectionReusableView? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            guard case .standard(let header) = header else {
                return nil
            }
            return header.makeSupplementaryView(ofKind: elementKind, for: collectionView, indexPath: indexPath, value: sectionIdentifier)

        case UICollectionView.elementKindSectionFooter:
            return footer?.makeSupplementaryView(ofKind: elementKind, for: collectionView, indexPath: indexPath, value: sectionIdentifier)
            
        default:
            return nil
        }
    }
}
