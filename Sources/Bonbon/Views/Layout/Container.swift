import UIKit


public class Container<Content>: UIView {

    // MARK: Properties

    public internal(set) var content: Content!
    public var allowsPassThrough: Bool = false

    public var container: UIView { self }


    // MARK: Instance life cycle

    public init(unarrangedContent: Content!) {
        self.content = unarrangedContent
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Instance life cycle

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        let shouldExclude = view == self || !(view?.isUserInteractionEnabled ?? false)
        return allowsPassThrough && shouldExclude ? nil : view
    }
}


// MARK: - Initializers

public extension Container {

    convenience init(content: Content, arrangeUsing contentConfigurator: (Content, Container<Content>) -> Void) {
        self.init(unarrangedContent: content)
        contentConfigurator(content, self)
    }

    convenience init(content: Content, arrangeUsing contentConfigurator: (Content) -> UIView) {
        self.init(unarrangedContent: content)

        if let content = content as? UIView {
            content.translatesAutoresizingMaskIntoConstraints = false
        }
        let subview = contentConfigurator(content)
        subview.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(subview)
        
        NSLayoutConstraint.activate([
            subview.leftAnchor.constraint(equalTo: self.leftAnchor),
            subview.rightAnchor.constraint(equalTo: self.rightAnchor),
            subview.topAnchor.constraint(equalTo: self.topAnchor),
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
}


public extension Container where Content: UIView {

    convenience init(content: Content) {
        self.init(content: content, arrangeUsing: { $0 })
    }
}


// MARK: - Modifiers

public extension Container {

    func allowsPassThrough(_ value: Bool) -> Self {
        self.allowsPassThrough = value
        return self
    }
}
