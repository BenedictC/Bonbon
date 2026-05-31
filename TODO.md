# TODO

- Update demo

## CollectionViewLayout
- Layout BoundarySupplement 

- SectionHeader
    - Add init that takes an optional view and value 
    - Add init that takes a ReusableContentView    
- SectionFooter
    - Add init that takes an optional view and value 
    - Add init that takes a ReusableContentView
- BoundarySupplement
    - Add init that takes a ReusableContentView
- Supplement
    - Add init that takes an optional view and value 

- SectionSupplement
- GroupSupplement
- GroupItemSupplement

- CustomGroup


- CellRegistration additions


- Remaining UIKit modifiers
    - GestureRecognizers
    - UIMenu, UIAction, UISwipeAction (and UICommand?)
    - Any others?

- Animation!
    
- Localization
    - Replicate LocalizedStringKey?
    
- Accessibility?
    
- Debug helpers?
    - Check if a view is being added multiple times during its parent's view's init


## Documentation

- Document all the things!
- Improve demo app and list what it illustrates:    
    - UIViewController subclassing 
    - Constructing a `View`'s layout that:
        - Abstract a layout to a `LayoutView` subclass
        - Uses Combine for state management
        - Keyboard avoidance
    - `FlowController`s for grouping view controllers
    - Async/await modal presentation of UIAlertController and a custom ViewController
    - A declarative `UICollectionView` layout  
