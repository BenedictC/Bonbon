import UIKit


// MARK: - ContainerViewController

public typealias ContainerViewController = _ContainerViewController & ContainerViewControllerRequirements


// MARK: - Associated Types

@MainActor
public protocol ContainerViewControllerRequirements: ViewControllerRequirements, _ContainerViewControllerRequirements {

    associatedtype ContentViewController: UIViewController

    var contentViewController: ContentViewController { get }
}


// MARK: - Core Implementation

@MainActor
public protocol _ContainerViewControllerRequirements: _ContainerViewController, _ViewControllerRequirements {

    var _contentViewController: UIViewController { get }
}


public extension ContainerViewControllerRequirements {

    var _rootView: UIView { rootView }
}


public extension ContainerViewControllerRequirements where Self: _ContainerViewController {

    var _contentViewController: UIViewController { contentViewController }
}

public extension ContainerViewControllerRequirements {

    var contentViewController: UINavigationController {
        // If we all ready have the container then we're done
        if let defaultContainerViewController = defaultContentViewController {
            return defaultContainerViewController
        }
        // Create and store the container
        let contentViewController = UINavigationController()
        defaultContentViewController = contentViewController
        return contentViewController
    }
}


public extension ContainerViewControllerRequirements {

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


open class _ContainerViewController: _ViewController {

    fileprivate var defaultContentViewController: UINavigationController?
    fileprivate var defaultRootView: UIView?

    public override init() {
        super.init()

        guard
            let contentVC = (self as? _ContainerViewControllerRequirements)?._contentViewController
        else {
            preconditionFailure("_ContainerViewController subclasses must conform to _ContainerViewControllerRequirements.")
        }
        self.addChild(contentVC)
        contentVC.didMove(toParent: self)
    }

    @available(*, unavailable, message: "Use viewDidLoad to configure the view.")
    override public func loadView() {
        guard let containerC = self as? _ContainerViewControllerRequirements else {
            preconditionFailure("_ContainerViewController subclasses must conform to _ContainerViewControllerRequirements.")
        }
        self.view = containerC._rootView
    }
}


// MARK: - UINavigationController additions

/// Core navigation methods
public extension ContainerViewControllerRequirements where ContentViewController: UINavigationController {

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
