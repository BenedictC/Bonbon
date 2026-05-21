import UIKit


// MARK: - ViewProperties

@available(swift 5.1)
@available(iOS, deprecated: 26, message: "Use .properties instead.")
public extension UIViewInvalidating where Self == _View.Invalidations.ViewProperties {

    static var viewProperties: _View.Invalidations.ViewProperties { _View.Invalidations.ViewProperties()  }
}


public extension _View {

    enum Invalidations {

        @available(iOS, deprecated: 26, message: "Use .properties instead.")
        public struct ViewProperties: UIViewInvalidating {

            public func invalidate(view: UIView) {
                guard let view = view as? _View else {
                    runtimeWarn("Attempted to invalided viewProperties of view that does not inherit from UICandy._View. Invalidation is not possible.")
                    return
                }
                view.setNeedsUpdateViewProperties()
            }
        }
    }
}


// MARK: - Optional handling

public extension UIView.Invalidating where Value: _AnyOptional {

    init(_ invalidation: InvalidationType) {
        self.init(wrappedValue: Value.none, invalidation)
    }
}
