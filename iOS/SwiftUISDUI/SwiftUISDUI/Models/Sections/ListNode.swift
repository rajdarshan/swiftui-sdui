//
//  ListNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §6: `items[]` M unless `filter` supplies items instead.
//  Same shape as RailNode minus `itemWidth`/`snap` — `list` isn't used on
//  the home screen (§13: "unused on this screen") but decodes per contract.
//

nonisolated struct ListNode: Decodable, Equatable {
    let id: String
    let header: SectionHeader?
    let style: Style?
    let filter: FilterNode?
    let items: [any ItemNode]?

    private enum CodingKeys: String, CodingKey { case id, header, style, filter, items }

    /// Memberwise — reconstructs a node with a trimmed `items`/`filter`,
    /// used by DuplicateItemIdResolution.swift. Not the Decodable path.
    init(id: String, header: SectionHeader?, style: Style?, filter: FilterNode?, items: [any ItemNode]?) {
        self.id = id
        self.header = header
        self.style = style
        self.filter = filter
        self.items = items
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
    }

    static func == (lhs: ListNode, rhs: ListNode) -> Bool {
        guard lhs.id == rhs.id, lhs.header == rhs.header, lhs.style == rhs.style, lhs.filter == rhs.filter else {
            return false
        }
        return (lhs.items?.map(\.id) ?? []) == (rhs.items?.map(\.id) ?? [])
    }
}
