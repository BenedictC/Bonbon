import UIKit


public enum CellRegistration { }


// MARK: - ContentConfiguration

public extension CellRegistration {

    static func withCell<Cell: UICollectionViewCell, ItemIdentifier: Hashable>(
        handler: @escaping UICollectionView.CellRegistration<Cell, ItemIdentifier>.Handler
    ) -> UICollectionView.CellRegistration<Cell, ItemIdentifier> {
        UICollectionView.CellRegistration(handler: handler)
    }
}


// MARK: - ContentConfiguration

public extension CellRegistration {

    static func withContentConfiguration<ItemIdentifier: Hashable>(
        configuration: @escaping (_ contentConfiguration: inout UIListContentConfiguration, _ indexPath: IndexPath, _ item: ItemIdentifier) -> Void
    ) -> UICollectionView.CellRegistration<UICollectionViewListCell, ItemIdentifier> {
        UICollectionView.CellRegistration<UICollectionViewListCell, ItemIdentifier>(handler: { cell, indexPath, item in
            var contentConfiguration = (cell.contentConfiguration as? UIListContentConfiguration) ?? cell.defaultContentConfiguration()
            configuration(&contentConfiguration, indexPath, item)
            cell.contentConfiguration = contentConfiguration
        })
    }
}


// MARK: - ContentView

public extension CellRegistration {

    static func withContentView<ItemIdentifier: Hashable, Content: UIView>(
        configuration: @escaping (_ existing: Content?,  _ indexPath: IndexPath, _ item: ItemIdentifier) -> Content,
    ) -> UICollectionView.CellRegistration<ContentCell<Content>, ItemIdentifier> {
        return UICollectionView.CellRegistration<ContentCell<Content>, ItemIdentifier>(handler: { cell, indexPath, item in
                let existing = cell.content
                let content = configuration(existing, indexPath, item)
                cell.setContentView(content)
            }
        )
    }
}


// MARK: - ContentView

public extension CellRegistration {

    static func withContentConfigurationAndSwitch<ItemIdentifier: Hashable>(
        configuration: @escaping (_ contentConfiguration: inout UIListContentConfiguration, _ uiSwitch: UISwitch, _ indexPath: IndexPath, _ item: ItemIdentifier) -> Void
    ) -> UICollectionView.CellRegistration<ContentCell<UISwitch>, ItemIdentifier> {
        return UICollectionView.CellRegistration<ContentCell<UISwitch>, ItemIdentifier>(handler: { cell, indexPath, item in
            let uiSwitch: UISwitch
            if let existing = cell.content {
                uiSwitch = existing
            } else {
                uiSwitch = UISwitch()
                cell.content = uiSwitch
                cell.accessories = [
                    .customView(configuration: UICellAccessory.CustomViewConfiguration(
                        customView: uiSwitch, placement: .trailing()
                    ))
                ]
            }

            var contentConfiguration = (cell.contentConfiguration as? UIListContentConfiguration) ?? cell.defaultContentConfiguration()
            configuration(&contentConfiguration, uiSwitch, indexPath, item)
            cell.contentConfiguration = contentConfiguration
        })
    }
}


public extension CellRegistration {

    static func withAccessories<ItemIdentifier: Hashable, Content>(
        configuration: @escaping (_ existing: Content?, _ contentConfiguration: inout UIListContentConfiguration, _ indexPath: IndexPath, _ item: ItemIdentifier) -> [UICellAccessory]
    ) -> UICollectionView.CellRegistration<ContentCell<Content>, ItemIdentifier> {

        return UICollectionView.CellRegistration<ContentCell<Content>, ItemIdentifier>(handler: { cell, indexPath, item in
            let stale = cell.content
            var contentConfiguration = (cell.contentConfiguration as? UIListContentConfiguration) ?? cell.defaultContentConfiguration()
            let fresh = configuration(stale, &contentConfiguration, indexPath, item)
            cell.contentConfiguration = contentConfiguration
            UIView.performWithoutAnimation {
                cell.accessories = fresh
            }
        })
    }
}


// MARK: - ItemRepresentable

public extension CellRegistration {

    @MainActor
    static func withItemCell<CellClass: UICollectionViewCell & ItemRepresentable>(
        _ cellClass: CellClass.Type,
    ) -> UICollectionView.CellRegistration<CellClass, CellClass.Item> {
        return UICollectionView.CellRegistration<CellClass, CellClass.Item>(handler: { cell, indexPath, itemIdentifier in
            cell.item = itemIdentifier
        })
    }
}
