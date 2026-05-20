import UIKit


@MainActor
@propertyWrapper
public struct Invalidating<Value> {

    // MARK: Types

    @MainActor
    public enum Invalidation {

        case statusBarAppearance
        case supportedInterfaceOrientations
        case screenEdgesDeferringSystemGestures
        case homeIndicatorAutoHidden
        case prefersPointerLocked
        @available(iOS 17, *)
        case contentUnavailableConfiguration
        @available(iOS 26, *)
        case prefersInterfaceOrientationLocked
        @available(iOS 26, *)
        case properties

        @available(iOS, deprecated: 26, message: "Use .properties instead")
        case viewProperties


        func invalidate(viewController: _ViewController) {
            switch self {
            case .statusBarAppearance:
                viewController.setNeedsStatusBarAppearanceUpdate()
            case .supportedInterfaceOrientations:
                viewController.setNeedsUpdateOfSupportedInterfaceOrientations()
            case .screenEdgesDeferringSystemGestures:
                viewController.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
            case .homeIndicatorAutoHidden:
                viewController.setNeedsUpdateOfHomeIndicatorAutoHidden()
            case .prefersPointerLocked:
                viewController.setNeedsUpdateOfPrefersPointerLocked()
            case .contentUnavailableConfiguration:
                if #available(iOS 17, *) {
                    viewController.setNeedsUpdateContentUnavailableConfiguration()
                }
            case .prefersInterfaceOrientationLocked:
                if #available(iOS 26, *) {
                    viewController.setNeedsUpdateOfPrefersInterfaceOrientationLocked()
                }
            case .properties:
                if #available(iOS 26, *) {
                    viewController.setNeedsUpdateProperties()
                }
            case .viewProperties:
                viewController.setNeedsUpdateViewProperties()
            }
        }
    }


    // MARK: Properties

    let invalidations: [Invalidation]
    var value: Value


    // MARK: Instance life cycle

    public init(wrappedValue: Value, _ invalidations: Invalidation...) {
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


// MARK: - Optional handling

public protocol _AnyOptional {

    static var none: Self { get }
}

extension Optional: _AnyOptional { }


public extension Invalidating where Value: _AnyOptional {

    init(_ invalidations: Invalidation...) {
        self.value = Value.none
        self.invalidations = invalidations
    }
}
