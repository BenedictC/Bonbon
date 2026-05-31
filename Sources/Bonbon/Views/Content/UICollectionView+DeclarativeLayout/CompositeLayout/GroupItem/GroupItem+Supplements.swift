
public extension GroupItem {

    func supplements(
        @ArrayBuilder<Supplement<SectionIdentifier, ItemIdentifier>>
        _ supplementsBuilder: () -> [Supplement<SectionIdentifier, ItemIdentifier>]
    ) -> SupplementedGroupItem<SectionIdentifier, ItemIdentifier> {
        let supplements = supplementsBuilder()
        return SupplementedGroupItem(groupItem: self.eraseToAnyGroupItem(), supplements: supplements)
    }
}

