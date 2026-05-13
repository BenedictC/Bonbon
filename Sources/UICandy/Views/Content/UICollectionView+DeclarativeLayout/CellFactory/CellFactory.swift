import UIKit


public struct CellFactory<ItemIdentifier> {

    // MARK: Types

    public typealias CellRegister = (UICollectionView) -> Void
    public typealias CellProvider = (UICollectionView, IndexPath, ItemIdentifier) -> (UICollectionViewCell?)


    // MARK: Properties

    let cellClass: AnyClass
    let reuseIdentifier: String
    let cellFactory: (UICollectionView, IndexPath, ItemIdentifier) -> UICollectionViewCell


    // MARK: Instance life cycle

    public init<CellType: UICollectionViewCell>(
        cellClass: CellType.Type? = nil,
        reuseIdentifier: String? = nil,
        reuseIdentifierFileID: @autoclosure () -> String = #fileID,
        reuseIdentifierLine: @autoclosure () -> Int = #line,
        reuseIdentifierColumn: @autoclosure () -> Int = #column,
        configuration: @escaping (CellType, IndexPath, ItemIdentifier) -> Void
    ) {
        self.cellClass = CellType.self
        self.reuseIdentifier = reuseIdentifier ?? {
            let base = "\(reuseIdentifierFileID()):\(reuseIdentifierLine()):\(reuseIdentifierColumn())"
            #if DEBUG
            return base
            #else
            return "\(base.hash)"
            #endif
        }()
        let reuseID = self.reuseIdentifier
        self.cellFactory = { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CellType
            configuration(cell, indexPath, item)
            return cell
        }
    }


    // MARK: Instance life cycle

    func registerCellClass(in collectionView: UICollectionView) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: reuseIdentifier)
    }

    func makeCell(for collectionView: UICollectionView, indexPath: IndexPath, item: ItemIdentifier) -> UICollectionViewCell? {
        registerCellClass(in: collectionView)
        return cellFactory(collectionView, indexPath, item)
    }
}
