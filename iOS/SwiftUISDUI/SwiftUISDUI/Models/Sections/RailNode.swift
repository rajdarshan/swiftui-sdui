//
//  RailNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §6: `items[]` M unless `filter` is present (which supplies
//  items instead — the `\*` footnote), `itemWidth` O (default `md`),
//  `snap` O (default `true`, matching RailView's own existing default,
//  Components/RailView.swift). `header`/`style` are common to every
//  section (§6's opening table); `filter` is valid on rail/grid/list only.
//

nonisolated struct RailNode: Decodable, Equatable {
    let id: String
    let header: SectionHeader?
    let style: Style?
    let filter: FilterNode?
    let items: [any ItemNode]?
    let itemWidth: ItemWidth
    let snap: Bool

    private enum CodingKeys: String, CodingKey { case id, header, style, filter, items, itemWidth, snap }

    /// Memberwise — reconstructs a node with a trimmed `items`/`filter`,
    /// used by DuplicateItemIdResolution.swift. Not the Decodable path.
    init(
        id: String,
        header: SectionHeader?,
        style: Style?,
        filter: FilterNode?,
        items: [any ItemNode]?,
        itemWidth: ItemWidth,
        snap: Bool
    ) {
        self.id = id
        self.header = header
        self.style = style
        self.filter = filter
        self.items = items
        self.itemWidth = itemWidth
        self.snap = snap
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        header = try container.decodeIfPresent(SectionHeader.self, forKey: .header)
        style = try container.decodeIfPresent(Style.self, forKey: .style)

        if container.contains(.filter) {
            filter = try container.decode(FilterNode.self, forKey: .filter)
            items = nil
        } else {
            filter = nil
            var itemsContainer = try container.nestedUnkeyedContainer(forKey: .items)
            items = try ItemArray.decode(from: &itemsContainer)
        }

        let widthRaw = try container.decodeIfPresent(String.self, forKey: .itemWidth)
        itemWidth = widthRaw.flatMap(ItemWidth.init(rawValue:)) ?? .md
        snap = try container.decodeIfPresent(Bool.self, forKey: .snap) ?? true
    }

    static func == (lhs: RailNode, rhs: RailNode) -> Bool {
        lhs.id == rhs.id
            && lhs.header == rhs.header
            && lhs.style == rhs.style
            && lhs.filter == rhs.filter
            && lhs.itemWidth == rhs.itemWidth
            && lhs.snap == rhs.snap
            && (lhs.items?.map(\.id) ?? []) == (rhs.items?.map(\.id) ?? [])
    }
}
