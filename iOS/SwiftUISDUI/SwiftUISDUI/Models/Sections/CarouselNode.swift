//
//  CarouselNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §6: `items[]` M (carousel isn't in the filter-valid list —
//  no filter alternative), `loop` O (default false), `peek` O (default
//  false), `autoScrollMs` O. `autoScrollMs` is decoded and stored even
//  though CarouselView doesn't consume it yet (Components/CarouselView.swift:
//  "autoScrollMs is deferred") — decoding is a Stage 3 concern independent
//  of what Stage 4's view layer currently wires up.
//

nonisolated struct CarouselNode: Decodable, Equatable {
    let id: String
    let header: SectionHeader?
    let style: Style?
    let items: [any ItemNode]
    let loop: Bool
    let peek: Bool
    let autoScrollMs: Int?

    private enum CodingKeys: String, CodingKey { case id, header, style, items, loop, peek, autoScrollMs }

    /// Memberwise — reconstructs a node with a trimmed `items`, used by
    /// DuplicateItemIdResolution.swift. Not the Decodable path.
    init(
        id: String,
        header: SectionHeader?,
        style: Style?,
        items: [any ItemNode],
        loop: Bool,
        peek: Bool,
        autoScrollMs: Int?
    ) {
        self.id = id
        self.header = header
        self.style = style
        self.items = items
        self.loop = loop
        self.peek = peek
        self.autoScrollMs = autoScrollMs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        header = try container.decodeIfPresent(SectionHeader.self, forKey: .header)
        style = try container.decodeIfPresent(Style.self, forKey: .style)
        var itemsContainer = try container.nestedUnkeyedContainer(forKey: .items)
        items = try ItemArray.decode(from: &itemsContainer)
        loop = try container.decodeIfPresent(Bool.self, forKey: .loop) ?? false
        peek = try container.decodeIfPresent(Bool.self, forKey: .peek) ?? false
        autoScrollMs = try container.decodeIfPresent(Int.self, forKey: .autoScrollMs)
    }

    static func == (lhs: CarouselNode, rhs: CarouselNode) -> Bool {
        guard lhs.id == rhs.id, lhs.loop == rhs.loop, lhs.peek == rhs.peek else { return false }
        guard lhs.autoScrollMs == rhs.autoScrollMs else { return false }
        return lhs.items.map(\.id) == rhs.items.map(\.id)
    }
}
