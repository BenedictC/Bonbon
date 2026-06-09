import UIKit


// MARK: - FlowController

public typealias FlowController = _FlowController & FlowControllerRequirements


// MARK: - Associated Types

@MainActor
public protocol FlowControllerRequirements: ViewControllerRequirements, _FlowControllerRequirements {

    associatedtype ContentViewController: UIViewController = UINavigationController

    var contentViewController: ContentViewController { get }
}


// MARK: - Core Implementation

@MainActor
public protocol _FlowControllerRequirements: _FlowController, _ViewControllerRequirements {

    var _contentViewController: UIViewController { get }
}


public extension FlowControllerRequirements {

    var _rootView: UIView { rootView }
}


public extension FlowControllerRequirements where Self: _FlowController {

    var _contentViewController: UIViewController { contentViewController }
}

/// Creates and configures a  NavigationController if one is not explicit set. Allows the vc to be declared with only the RootViewController
public extension FlowControllerRequirements where Self: _FlowController, ContentViewController: UINavigationController {

    var contentViewController: ContentViewController {
        // If we all ready have the container then we're done
        if let defaultContainerViewController = defaultContentViewController as? ContentViewController {
            return defaultContainerViewController
        }
        // Create and store the container
        let contentViewController = ContentViewController()
        defaultContentViewController = contentViewController
        return contentViewController
    }
}


public extension FlowControllerRequirements {

    var rootView: UIView {
        if let defaultRootView {
            return defaultRootView
        }
        let rootView = UIView()
        rootView.backgroundColor = .systemBackground
        let contentView = _contentViewController.view!
        contentView.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: rootView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rootView.rightAnchor),
            contentView.topAnchor.constraint(equalTo: rootView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
        ])
        self.defaultRootView = rootView
        return rootView
    }
}


open class _FlowController: _ViewController {

    fileprivate var defaultContentViewController: UIViewController?
    fileprivate var defaultRootView: UIView?

    @available(*, unavailable, message: "Use viewDidLoad to configure the view.")
    override public func loadView() {
        guard let flowC = self as? _FlowControllerRequirements else {
            preconditionFailure("_FlowController subclasses must conform to _FlowControllerRequirements.")
        }
        let contentVC = flowC._contentViewController
        contentVC.willMove(toParent: self)
        self.view = flowC._rootView
        addChild(contentVC)
    }
}


// MARK: - UINavigationController additions

/// Core navigation methods
public extension FlowControllerRequirements where ContentViewController: UINavigationController {

    func push(_ viewController: UIViewController, animated: Bool) {
        contentViewController.pushViewController(viewController, animated: animated)
    }

    func pop(animated: Bool) {
        contentViewController.popViewController(animated: animated)
    }

    func pop(to child: UIViewController, animated: Bool) {
        contentViewController.popToViewController(child, animated: animated)
    }

    func popToRoot(animated: Bool) {
        contentViewController.popToRootViewController(animated: animated)
    }
}
