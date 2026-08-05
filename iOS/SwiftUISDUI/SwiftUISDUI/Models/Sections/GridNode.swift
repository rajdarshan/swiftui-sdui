//
//  GridNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §6: `items[]` M unless `filter` supplies items instead,
//  `columns` M (2-4). The 2-4 bound isn't covered by §10's fallback table
//  explicitly — resolved the same way as placeCard's cardinality gap:
//  treated as malformed (decode throws), not silently clamped.
//

nonisolated struct GridNode: Decodable, Equatable {
    let id: String
    let header: SectionHeader?
    let style: Style?
    let filter: FilterNode?
    let items: [any ItemNode]?
    let columns: Int

    private enum CodingKeys: String, CodingKey { case id, header, style, filter, items, columns }

    /// Memberwise — reconstructs a node with a trimmed `items`/`filter`,
    /// used by DuplicateItemIdResolution.swift. Not the Decodable path.
    init(
        id: String,
        header: SectionHeader?,
        style: Style?,
        filter: FilterNode?,
        items: [any ItemNode]?,
        columns: Int
    ) {
        self.id = id
        self.header = header
        self.style = style
        self.filter = filter
        self.items = items
        self.columns = columns
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

        let decodedColumns = try container.decode(Int.self, forKey: .columns)
        guard (2...4).contains(decodedColumns) else {
            throw DecodingError.dataCorruptedError(
                forKey: .columns,
                in: container,
                debugDescription: "COMPONENTS.md §6: grid.columns must be 2-4"
            )
        }
        columns = decodedColumns
    }

    static func == (lhs: GridNode, rhs: GridNode) -> Bool {
        lhs.id == rhs.id
            && lhs.header == rhs.header
            && lhs.style == rhs.style
            && lhs.filter == rhs.filter
            && lhs.columns == rhs.columns
            && (lhs.items?.map(\.id) ?? []) == (rhs.items?.map(\.id) ?? [])
    }
}
