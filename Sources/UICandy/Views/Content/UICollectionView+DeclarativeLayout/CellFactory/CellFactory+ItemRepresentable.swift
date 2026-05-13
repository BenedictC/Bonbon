import UIKit


// MARK: - ItemRepresentable

@available(iOS 14, *)
public extension CellFactory {

    @MainActor
    init<CellClass: UICollectionViewCell & ItemRepresentable>(
        _ cellClass: CellClass.Type,
        reuseIdentifier: String? = nil,
    ) where CellClass.Item == ItemIdentifier {
        self.init(
            cellClass: cellClass,
            reuseIdentifier: reuseIdentifier,
            configuration: { cell, _, item in
                cell.item = item
            }
        )
    }
}
