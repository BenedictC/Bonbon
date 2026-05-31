import UIKit


public class ContentCell<Content>: UICollectionViewListCell {

    @available(*, unavailable)
    override public var contentView: UIView {
        super.contentView
    }

    var contentContainer: UIView {
        super.contentView
    }

    public var content: Content? {
        didSet {
            if let oldValue = oldValue as? UIView, oldValue.superview == contentContainer,
            let newValue = content as? UIView, oldValue !== newValue {
                oldValue.removeFromSuperview()
            }
        }
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        if let content = content as? UIView, content.superview == contentContainer {
            content.removeFromSuperview()
        }
        content = nil
    }
}

public extension ContentCell where Content: UIView {

    func setContentView(_ fresh: Content?) {
        self.content = fresh

        let isChanged = content != fresh
        let shouldArrange = fresh?.superview != contentContainer
        guard isChanged || shouldArrange else { return }

        if let fresh {
            contentContainer.addSubview(fresh)
            fresh.translatesAutoresizingMaskIntoConstraints = false
            let layoutGuide = contentContainer.layoutMarginsGuide
            NSLayoutConstraint.activate([
                fresh.leftAnchor.constraint(equalTo: layoutGuide.leftAnchor),
                fresh.rightAnchor.constraint(equalTo: layoutGuide.rightAnchor),
                fresh.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
                fresh.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            ])
        }
    }
}
