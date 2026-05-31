import UIKit


public extension UINavigationController {

    convenience init(delegate: UINavigationControllerDelegate?) {
        self.init()
        self.delegate = delegate
    }

    convenience init(delegate: UINavigationControllerDelegate?, @ArrayBuilder<UIViewController> controllers stackBuilder: () -> [UIViewController]) {
        let stack = stackBuilder()
        self.init()
        self.setViewControllers(stack, animated: false)
        self.delegate = delegate
    }

    convenience init(@ArrayBuilder<UIViewController> controllers stackBuilder: () -> [UIViewController]) {
        let stack = stackBuilder()
        self.init()
        self.setViewControllers(stack, animated: false)
    }
}
