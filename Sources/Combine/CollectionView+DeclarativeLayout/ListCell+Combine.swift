import Combine


// MARK: - Published Value

public extension CellFactory {

    static func withContent(
        contentBuilder: @escaping (UICollectionViewCell, any CurrentValuePublisher<ItemIdentifier, Never>) -> UIView
    ) -> CellFactory<ItemIdentifier> {
        typealias CellType = ValuePublishingCell<ItemIdentifier>
        let reuseIdentifier = UniqueIdentifier("\(CellType.self)").value
        return CellFactory(
            cellRegistrar: { collectionView in
                collectionView.register(CellType.self, forCellWithReuseIdentifier: reuseIdentifier)
            },
            cellProvider: { collectionView, indexPath, value in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CellType
                cell.initialize(bodyProvider: contentBuilder)
                cell.configure(withValue: value)
                return cell
            }
        )
    }
}
