import UIKit


public extension UIControl {

    func removeAllEventHandlers() {
        enumerateEventHandlers { action, targetAndAction, event, _ in
            if let action {
                self.removeAction(action, for: event)
            }
            if let targetAndAction {
                let (target, action) = targetAndAction
                self.removeTarget(target, action: action, for: event)
            }
        }
    }
}
