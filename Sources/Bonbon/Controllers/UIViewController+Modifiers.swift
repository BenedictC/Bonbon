import UIKit


public protocol SomeViewController: UIViewController { }

public extension SomeViewController {

    func configure(using configuration: (Self) -> Void) -> Self {
        configuration(self)
        return self
    }
}
