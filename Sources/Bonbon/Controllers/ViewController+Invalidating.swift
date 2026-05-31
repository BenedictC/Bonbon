import UIKit


@MainActor
public protocol ViewControllerInvalidating {

    func invalidate(viewController: _ViewController)
}



public extension ViewControllerInvalidating where Self == _ViewController.Invalidation.StatusBarAppearance {
    static var statusBarAppearance: _ViewController.Invalidation.StatusBarAppearance { Self()  }
}
public extension ViewControllerInvalidating where Self == _ViewController.Invalidation.SupportedInterfaceOrientations {
    static var supportedInterfaceOrientations: _ViewController.Invalidation.SupportedInterfaceOrientations { Self()  }
}
public extension ViewControllerInvalidating where Self == _ViewController.Invalidation.ScreenEdgesDeferringSystemGestures {
    static var screenEdgesDeferringSystemGestures: _ViewController.Invalidation.ScreenEdgesDeferringSystemGestures { Self()  }
}
public extension ViewControllerInvalidating where Self == _ViewController.Invalidation.HomeIndicatorAutoHidden {
    static var homeIndicatorAutoHidden: _ViewController.Invalidation.HomeIndicatorAutoHidden { Self()  }
}
public extension ViewControllerInvalidating where Self == _ViewController.Invalidation.PrefersPointerLocked {
    static var prefersPointerLocked: _ViewController.Invalidation.PrefersPointerLocked { Self()  }
}
@available(iOS 17, *)
public extension ViewControllerInvalidating where Self == _ViewController.Invalidation.ContentUnavailableConfiguration {
    static var contentUnavailableConfiguration: _ViewController.Invalidation.ContentUnavailableConfiguration { Self()  }
}
@available(iOS 26, *)
public extension ViewControllerInvalidating where Self == _ViewController.Invalidation.PrefersInterfaceOrientationLocked {
    static var prefersInterfaceOrientationLocked: _ViewController.Invalidation.PrefersInterfaceOrientationLocked { Self()  }
}
@available(iOS 26, *)
public extension ViewControllerInvalidating where Self == _ViewController.Invalidation.Properties {
    static var properties: _ViewController.Invalidation.Properties { Self()  }
}
@available(iOS, deprecated: 26, message: "Use .properties instead")
public extension ViewControllerInvalidating where Self == _ViewController.Invalidation.ViewProperties {
    static var viewProperties: _ViewController.Invalidation.ViewProperties { Self()  }
}


public extension _ViewController {

    @MainActor
    enum Invalidation {

        public struct StatusBarAppearance: ViewControllerInvalidating {
            public init() { }
            public func invalidate(viewController: _ViewController) { viewController.setNeedsStatusBarAppearanceUpdate() }
        }
        public struct SupportedInterfaceOrientations: ViewControllerInvalidating {
            public init() { }
            public func invalidate(viewController: _ViewController) { viewController.setNeedsUpdateOfSupportedInterfaceOrientations() }
        }
        public struct ScreenEdgesDeferringSystemGestures: ViewControllerInvalidating {
            public init() { }
            public func invalidate(viewController: _ViewController) { viewController.setNeedsUpdateOfScreenEdgesDeferringSystemGestures() }
        }
        public struct HomeIndicatorAutoHidden: ViewControllerInvalidating {
            public init() { }
            public func invalidate(viewController: _ViewController) { viewController.setNeedsUpdateOfHomeIndicatorAutoHidden() }
        }
        public struct PrefersPointerLocked: ViewControllerInvalidating {
            public init() { }
            public func invalidate(viewController: _ViewController) { viewController.setNeedsUpdateOfPrefersPointerLocked() }
        }
        @available(iOS 17, *)
        public struct ContentUnavailableConfiguration: ViewControllerInvalidating {
            public init() { }
            public func invalidate(viewController: _ViewController) { viewController.setNeedsUpdateContentUnavailableConfiguration() }
        }
        @available(iOS 26, *)
        public struct PrefersInterfaceOrientationLocked: ViewControllerInvalidating {
            public init() { }
            public func invalidate(viewController: _ViewController) { viewController.setNeedsUpdateOfPrefersInterfaceOrientationLocked() }
        }
        @available(iOS 26, *)
        public struct Properties: ViewControllerInvalidating {
            public init() { }
            public func invalidate(viewController: _ViewController) { viewController.setNeedsUpdateProperties() }
        }
        @available(iOS, deprecated: 26, message: "Use .properties instead")
        public struct ViewProperties: ViewControllerInvalidating {
            public init() { }
            public func invalidate(viewController: _ViewController) { viewController.setNeedsUpdateViewProperties() }
        }
    }


    @MainActor
    @propertyWrapper
    struct Invalidating<Value> {

        // MARK: Properties

        let invalidations: [any ViewControllerInvalidating]
        var value: Value


        // MARK: Instance life cycle

        public init(wrappedValue: Value, _ invalidations: ViewControllerInvalidating...) {
            self.value = wrappedValue
            self.invalidations = invalidations
        }


        // MARK: Accessor

        public static subscript<T: _ViewController>(
            _enclosingInstance viewController: T,
            wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
            storage storageKeyPath: ReferenceWritableKeyPath<T, Invalidating<Value>>
        ) -> Value {
            get {
                let value = viewController[keyPath: storageKeyPath].value
                return value
            }
            set {
                var wrapper = viewController[keyPath: storageKeyPath]
                wrapper.value = newValue
                wrapper.invalidate(viewController: viewController)
                viewController[keyPath: storageKeyPath] = wrapper
            }
        }

        @available(*, unavailable)
        public var wrappedValue: Value {
            get { value }
            set { value = newValue }
        }

        public var projectedValue: Invalidating<Value> { self }


        // MARK: Invalidation

        func invalidate(viewController: _ViewController) {
            for invalidation in invalidations {
                invalidation.invalidate(viewController: viewController)
            }
        }
    }
}


// MARK: - Optional handling

public extension ViewController.Invalidating where Value: _AnyOptional {

    init(_ invalidations: ViewControllerInvalidating...) {
        self.value = Value.none
        self.invalidations = invalidations
    }
}


//import UIKit
//
//
//@MainActor
//public protocol ViewControllerInvalidating {
//
//    func invalidate(viewController: _ViewController)
//}
//
//
//public extension UIViewInvalidating where Self == _ViewController.Invalidations {
//
//    static var statusBarAppearance: ViewControllerInvalidating { _ViewController.Invalidations(invalidator: { $0.setNeedsStatusBarAppearanceUpdate() }) }
//    static var supportedInterfaceOrientations: ViewControllerInvalidating { _ViewController.Invalidations(invalidator: { $0.setNeedsUpdateOfSupportedInterfaceOrientations() }) }
//    static var screenEdgesDeferringSystemGestures: ViewControllerInvalidating { _ViewController.Invalidations(invalidator: { $0.setNeedsUpdateOfScreenEdgesDeferringSystemGestures() }) }
//    static var homeIndicatorAutoHidden: ViewControllerInvalidating { _ViewController.Invalidations(invalidator: { $0.setNeedsUpdateOfHomeIndicatorAutoHidden() }) }
//    static var prefersPointerLocked: ViewControllerInvalidating { _ViewController.Invalidations(invalidator: { $0.setNeedsUpdateOfPrefersPointerLocked() }) }
//    @available(iOS 17, *)
//    static var contentUnavailableConfiguration: ViewControllerInvalidating { _ViewController.Invalidations(invalidator: { $0.setNeedsUpdateContentUnavailableConfiguration() }) }
//    @available(iOS 26, *)
//    static var prefersInterfaceOrientationLocked: ViewControllerInvalidating { _ViewController.Invalidations(invalidator: { $0.setNeedsUpdateOfPrefersInterfaceOrientationLocked() }) }
//    @available(iOS 26, *)
//    static var properties: ViewControllerInvalidating { _ViewController.Invalidations(invalidator: { $0.setNeedsUpdateProperties() }) }
//
//    @available(iOS, deprecated: 26, message: "Use .properties instead")
//    static var viewProperties: ViewControllerInvalidating { _ViewController.Invalidations(invalidator: { $0.setNeedsUpdateViewProperties() }) }
//}
//
//
//public extension _ViewController {
//
//    // MARK: Types
//
//    @MainActor
//    struct Invalidations: ViewControllerInvalidating {
//
//        let invalidator: (_ViewController) -> Void
//
//        public func invalidate(viewController: _ViewController) {
//            invalidator(viewController)
//        }
//    }
//
//    @MainActor
//    @propertyWrapper
//    struct Invalidating<Value> {
//
//        // MARK: Properties
//
//        let invalidations: [ViewControllerInvalidating]
//        var value: Value
//
//
//        // MARK: Instance life cycle
//
//        public init(wrappedValue: Value, _ invalidations: ViewControllerInvalidating...) {
//            self.value = wrappedValue
//            self.invalidations = invalidations
//        }
//
//
//        // MARK: Accessor
//
//        public static subscript<T: _ViewController>(
//            _enclosingInstance viewController: T,
//            wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
//            storage storageKeyPath: ReferenceWritableKeyPath<T, Invalidating<Value>>
//        ) -> Value {
//            get {
//                let value = viewController[keyPath: storageKeyPath].value
//                return value
//            }
//            set {
//                var wrapper = viewController[keyPath: storageKeyPath]
//                wrapper.value = newValue
//                wrapper.invalidate(viewController: viewController)
//                viewController[keyPath: storageKeyPath] = wrapper
//            }
//        }
//
//        @available(*, unavailable)
//        public var wrappedValue: Value {
//            get { value }
//            set { value = newValue }
//        }
//
//        public var projectedValue: Invalidating<Value> { self }
//
//
//        // MARK: Invalidation
//
//        func invalidate(viewController: _ViewController) {
//            for invalidation in invalidations {
//                invalidation.invalidate(viewController: viewController)
//            }
//        }
//    }
//}
//
//
//// MARK: - Optional handling
//
//public extension ViewController.Invalidating where Value: _AnyOptional {
//
//    init(_ invalidations: ViewControllerInvalidating...) {
//        self.value = Value.none
//        self.invalidations = invalidations
//    }
//}
