import UIKit


public typealias View = _View & ViewBodyProvider


// MARK: - Implementation

open class _View: UIView {

    // MARK: Properties

    private var isUpdateViewPropertiesNeeded = true


    // MARK: Instance life cycle

    public init() {
        super.init(frame: .zero)
        Self.initializeBodyHosting(of: self)
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Layout

    open override func layoutSubviews() {
        performUpdateViewProperties()
        super.layoutSubviews()
    }

    @available(iOS, deprecated: 26, message: "Call setNeedsUpdateProperties() instead.")
    open func setNeedsUpdateViewProperties() {
        isUpdateViewPropertiesNeeded = true
        setNeedsLayout()
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

public extension _View {

    func arrangeBody(_ body: UIView, in container: UIView) {
        container.addAndFill(subview: body, edgesIgnoringSafeArea: .all)
    }
}


public extension ViewBodyProvider where Self: _View {

    var body: Self { self }
}


// MARK: - Compile-time conformance check

private class CompilationCheck: View {
    let body = UIView()
}
