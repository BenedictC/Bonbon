import UIKit


// MARK: - ContentConfiguration

@available(iOS 14, *)
public extension CellFactory {

    static func withContentConfiguration(
        reuseIdentifier: String? = nil,
        configuration: @escaping (_ contentConfiguration: inout UIListContentConfiguration, _ indexPath: IndexPath, _ item: ItemIdentifier) -> Void
    ) -> Self {
        CellFactory(
            cellClass: UICollectionViewListCell.self,
            reuseIdentifier: reuseIdentifier,
            configuration: { cell, indexPath, item in
                var contentConfiguration = cell.defaultContentConfiguration()
                configuration(&contentConfiguration, indexPath, item)
                cell.contentConfiguration = contentConfiguration
            }
        )
    }
}


// MARK: - ContentConfiguration

@available(iOS 14, *)
public extension CellFactory {

    private class ContentViewCell<Content: UIView>: UICollectionViewListCell {

        var content: Content? {
            didSet {
                oldValue?.removeFromSuperview()
                if let content {
                    contentView.addSubview(content)
                    content.translatesAutoresizingMaskIntoConstraints = false
                    let layoutGuide = contentView.layoutMarginsGuide
                    NSLayoutConstraint.activate([
                        content.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor),
                        content.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor),
                        content.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
                        content.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
                    ])
                }
            }
        }
    }

    static func withContentView(
        reuseIdentifier: String? = nil,
        configuration: @escaping (_ indexPath: IndexPath, _ item: ItemIdentifier) -> UIView,
    ) -> Self {
        return CellFactory(
            cellClass: ContentViewCell<UIView>.self,
            reuseIdentifier: reuseIdentifier,
            configuration: { cell, indexPath, item in
                let content = configuration(indexPath, item)
                cell.content = content
            }
        )
    }
}


@available(iOS 14, *)
public extension CellFactory {

    static func withContentAndSwitch(
        reuseIdentifier: String? = nil,
        configuration: @escaping (_ contentConfiguration: inout UIListContentConfiguration, _ uiSwitch: UISwitch, _ indexPath: IndexPath, _ item: ItemIdentifier) -> Void
    ) -> Self {
        return CellFactory(
            cellClass: UICollectionViewListCell.self,
            reuseIdentifier: reuseIdentifier,
            configuration: { cell, indexPath, item in
                var contentConfiguration = cell.defaultContentConfiguration()
                let uiSwitch = UISwitch()
                configuration(&contentConfiguration, uiSwitch, indexPath, item)

                cell.contentConfiguration = contentConfiguration
                cell.accessories = [
                    .customView(configuration: UICellAccessory.CustomViewConfiguration(
                        customView: uiSwitch, placement: .trailing()
                    ))
                ]
            }
        )
    }
}


@available(iOS 16, *)
public extension CellFactory {

    static func withContentAndMenu(
        reuseIdentifier: @autoclosure () -> String = "\(#file):\(#line):\(#column)",
        configuration: @escaping (_ contentConfiguration: inout UIListContentConfiguration, _ indexPath: IndexPath, _ item: ItemIdentifier) -> UIMenu
    ) -> Self {
        return CellFactory(
            cellClass: UICollectionViewListCell.self,
            reuseIdentifier: reuseIdentifier(),
            configuration: { cell, indexPath, item in

                var contentConfiguration = cell.defaultContentConfiguration()
                let menu = configuration(&contentConfiguration, indexPath, item)

                cell.contentConfiguration = contentConfiguration
                cell.accessories = [
                    .label(text: "What?"),
                    .popUpMenu(menu),
                ]
            }
        )
    }
}
