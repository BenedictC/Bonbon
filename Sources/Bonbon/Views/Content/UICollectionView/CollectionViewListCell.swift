import UIKit


// MARK: - CollectionViewListCell

public typealias CollectionViewListCell = _CollectionViewListCell
                                    & ItemRepresentable
                                    & ViewBodyProvider

open class _CollectionViewListCell: UICollectionViewListCell, ReuseIdentifiable {

    // MARK: Properties

    public var bodyContainer: UIView { contentView }
    private var isUpdateViewPropertiesNeeded = true


    // MARK: Instance life cycle

    required public override init(frame: CGRect) {
        super.init(frame: frame)
        Self.initializeBodyHosting(of: self)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Layout

    open override func updateConfiguration(using state: UICellConfigurationState) {
        performUpdateViewProperties()
        super.updateConfiguration(using: state)
    }

    @available(iOS, deprecated: 26, message: "Call setNeedsUpdateProperties() instead.")
    open func setNeedsUpdateViewProperties() {
        isUpdateViewPropertiesNeeded = true
        setNeedsUpdateConfiguration()
    }

    open func updateViewPropertiesIfNeeded() {
        performUpdateViewProperties()
    }

    @available(iOS, deprecated: 26, message: "Override updateProperties() instead.")
    open func updateViewProperties() {
        // Do nothing. For subclasses to override
    }

    private func performUpdateViewProperties() {
        guard isUpdateViewPropertiesNeeded else {
            return
        }
        isUpdateViewPropertiesNeeded = false

        // Perform update
        updateViewProperties()
    }
}


// MARK: - ViewBodyProvider

extension _CollectionViewListCell {

    public func arrangeBody(_ body: UIView, in container: UIView) {
        body.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(body)
        NSLayoutConstraint.activate([
            body.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
            body.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            body.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor),
            body.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor),
        ])
    }
}


// MARK: - Compile-time conformance check

private class CompilationCheck: CollectionViewListCell {

    var body: UIView { contentView }
}

