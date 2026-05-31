import UIKit


@MainActor
public struct HGroup<SectionIdentifier: Hashable, ItemIdentifier: Hashable>: AxisGroup {

    public static var axis: AxisGroupAxis { .horizontal }

    public let groupSize: NSCollectionLayoutSize?
    public let items: [AnyGroupItem<SectionIdentifier, ItemIdentifier>]
    public let layoutGroupItemsProvider: LayoutGroupItemsProvider

    public init(
        groupSize: NSCollectionLayoutSize?,
        items: [AnyGroupItem<SectionIdentifier, ItemIdentifier>],
        layoutGroupItemsProvider: @escaping LayoutGroupItemsProvider
        ) {
        self.groupSize = groupSize
        self.items = items
        self.layoutGroupItemsProvider = layoutGroupItemsProvider
    }
}
