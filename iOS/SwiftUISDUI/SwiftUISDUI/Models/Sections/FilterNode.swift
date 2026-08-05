//
//  FilterNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §7: `chips` M, minimum 2. `defaultChipId` M — no match
//  falls back to index 0 (§10). A chip count below 2 isn't covered by §10's
//  table explicitly; resolved the same way as the placeCard cardinality
//  gap — treated as malformed (decode throws), not silently accepted.
//
//  `chip.items` reuses the same heterogeneous item decode (`ItemArray`) as
//  rail/grid/list — a chip is just an alternate item source for its parent
//  section (§6's `\*` footnote: filter supplies items instead of the
//  container's own `items[]`).
//

nonisolated struct FilterNode: Decodable, Equatable {
    let defaultChipId: String
    let chips: [ChipNode]

    private enum CodingKeys: String, CodingKey { case defaultChipId, chips }

    /// Memberwise — reconstructs with trimmed chips, used by
    /// DuplicateItemIdResolution.swift. Not the Decodable path. Skips the
    /// minimum-2 guard: only called with an already-valid decoded `chips`.
    init(defaultChipId: String, chips: [ChipNode]) {
        self.defaultChipId = defaultChipId
        self.chips = chips
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultChipId = try container.decode(String.self, forKey: .defaultChipId)
        let decodedChips = try container.decode([ChipNode].self, forKey: .chips)
        guard decodedChips.count >= 2 else {
            throw DecodingError.dataCorruptedError(
                forKey: .chips,
                in: container,
                debugDescription: "COMPONENTS.md §7: filter.chips requires at least 2 chips"
            )
        }
        chips = decodedChips
    }

    /// COMPONENTS.md §10: defaultChipId matches no chip → index 0.
    var defaultChip: ChipNode {
        chips.first { $0.id == defaultChipId } ?? chips[0]
    }
}

nonisolated struct ChipNode: Decodable, Identifiable {
    let id: String
    let label: String
    let items: [any ItemNode]

    private enum CodingKeys: String, CodingKey { case id, label, items }

    /// Memberwise — reconstructs with trimmed items, used by
    /// DuplicateItemIdResolution.swift. Not the Decodable path.
    init(id: String, label: String, items: [any ItemNode]) {
        self.id = id
        self.label = label
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        var itemsContainer = try container.nestedUnkeyedContainer(forKey: .items)
        items = try ItemArray.decode(from: &itemsContainer)
    }
}

extension ChipNode: Equatable {
    // `[any ItemNode]` isn't Equatable — id/label equality is sufficient
    // for tests (mirrors item ids being page-scoped-unique, COMPONENTS.md §8).
    static func == (lhs: ChipNode, rhs: ChipNode) -> Bool {
        lhs.id == rhs.id && lhs.label == rhs.label
    }
}
