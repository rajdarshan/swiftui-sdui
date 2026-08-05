//
//  SingleNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §6: `item` M, singular (not an array) — no `filter`,
//  since a single-item section has nothing to select between. A missing or
//  unrenderable `item` (decodeItem returns nil — unknown type, no usable
//  fallback) fails the same way any other missing mandatory prop does:
//  the section's own decode throws, so decodeSection's `try?` skips it.
//

nonisolated struct SingleNode: Decodable, Equatable {
    let id: String
    let header: SectionHeader?
    let style: Style?
    let item: any ItemNode

    private enum CodingKeys: String, CodingKey { case id, header, style, item }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        header = try container.decodeIfPresent(SectionHeader.self, forKey: .header)
        style = try container.decodeIfPresent(Style.self, forKey: .style)

        let itemDecoder = try container.superDecoder(forKey: .item)
        guard let decodedItem = decodeItem(from: itemDecoder) else {
            throw DecodingError.dataCorruptedError(
                forKey: .item,
                in: container,
                debugDescription: "COMPONENTS.md §6: single.item is mandatory and must be renderable"
            )
        }
        item = decodedItem
    }

    static func == (lhs: SingleNode, rhs: SingleNode) -> Bool {
        lhs.id == rhs.id && lhs.header == rhs.header && lhs.style == rhs.style && lhs.item.id == rhs.item.id
    }
}
