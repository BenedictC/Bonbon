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
                if let view = view as? _View {
                    view.setNeedsUpdateViewProperties()
                    return
                }
                if let view = view as? _Control {
                    view.setNeedsUpdateViewProperties()
                    return
                }
                if let view = view as? _CollectionViewCell {
                    view.setNeedsUpdateViewProperties()
                    return
                }
                if let view = view as? _CollectionViewListCell {
                    view.setNeedsUpdateViewProperties()
                    return
                }
                if let view = view as? _CollectionReusableView {
                    view.setNeedsUpdateViewProperties()
                    return
                }

                runtimeWarn("Attempted to invalidate viewProperties of view that does not inherit from Bonbon._View. Invalidation is not possible.")
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
