import UIKit


public struct SupplementaryRegistration<Section: Hashable, Item: Hashable> {

    public typealias Handler<T> = (T, IndexPath, Section, Item?) -> Void

    let dequeue: (UICollectionView, IndexPath, Section, Item?) -> UICollectionReusableView
    let configure: Handler<UICollectionReusableView>

    public func dequeueSupplementary(collectionView: UICollectionView, indexPath: IndexPath, section: Section, item: Item?) -> UICollectionReusableView {
        let view = dequeue(collectionView, indexPath, section, item)
        configure(view, indexPath, section, item)
        return view
    }

    public func configureSupplementaryView(_ supplementaryView: UICollectionReusableView, indexPath: IndexPath, section: Section, item: Item?) {
        configure(supplementaryView, indexPath, section, item)
    }
}


public extension SupplementaryRegistration {

    init<Supplement: UICollectionReusableView>(elementKind: String, handler: @escaping Handler<Supplement>) {
        let registration = UICollectionView.SupplementaryRegistration(elementKind: elementKind) { (supplementaryView: Supplement, elementKind, indexPath) in }
        self.dequeue = { collectionView, indexPath, section, item in
            collectionView.dequeueConfiguredReusableSupplementary(using: registration, for: indexPath)
        }
        self.configure = { (supplementaryView: UICollectionReusableView, indexPath: IndexPath, section: Section, item: Item?) in
            handler(supplementaryView as! Supplement, indexPath, section, item)
        }
    }

}
