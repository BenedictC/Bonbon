import UIKit


// MARK: - AnyListSection

@MainActor
public struct AnyListSection<SectionIdentifier: Hashable, ItemIdentifier: Hashable> {

    // MARK: Types

    public enum HeaderKind {
        case none
        case standard(SectionHeader<SectionIdentifier>)
        case collapsable
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

    var elementKinds: [String] {
        var elementKinds = [String]()
        switch header {
        case .standard(let header):
            elementKinds.append(header.elementKind)
        case .collapsable:
            break
        case .none:
            break
        }
        if let footer {
            elementKinds.append(footer.elementKind)
        }
        return elementKinds
    }


    // MARK: View creation

    func supplementaryRegistration(for collectionView: UICollectionView, elementKind: String, indexPath: IndexPath, sectionIdentifier: SectionIdentifier) -> SupplementaryRegistration<SectionIdentifier, ItemIdentifier>? {
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            guard case .standard(let header) = header else {
                return nil
            }
            return header.asSupplementaryRegistration()

        case UICollectionView.elementKindSectionFooter:
            return footer?.asSupplementaryRegistration()

        default:
            return nil
        }
    }
}
