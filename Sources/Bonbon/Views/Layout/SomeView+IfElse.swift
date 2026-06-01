import UIKit


public extension SomeView where Self: UIView {

    func `if`<T: SomeView>(_ condition: Bool, then ifTransform: (Self) -> T, else elseTransform: (Self) -> T) -> T {
        condition ? ifTransform(self) : elseTransform(self)
    }
}
