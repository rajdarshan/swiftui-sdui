//
//  ComponentRegistry.swift
//  SwiftUISDUI
//
//  design_spec.md §3.2 rule 3: "Registry is a dictionary keyed by the type
//  string, holding a decode closure and a view closure per type. Not a
//  Swift enum." Stage 3 builds the decode half only — Stage 4 adds a
//  parallel `itemViews` field to this same struct for rendering; adding a
//  future component stays "one new file plus one registration line" per
//  dictionary.
//
//  `nonisolated`: constructed and read from Decodable's nonisolated
//  `init(from:)` contexts (design_spec.md §3.3: unit testable with no
//  running app), while the module otherwise defaults every declaration to
//  @MainActor.
//

nonisolated struct ComponentRegistry {
    let itemDecoders: [String: (Decoder) throws -> any ItemNode]

    static let shared = ComponentRegistry(itemDecoders: [
        "tile": { try TileNode(from: $0) },
        "modelCard": { try ModelCardNode(from: $0) },
        "iconTile": { try IconTileNode(from: $0) },
        "carCard": { try CarCardNode(from: $0) },
        "placeCard": { try PlaceCardNode(from: $0) },
        "promoCard": { try PromoCardNode(from: $0) },
        "featureCard": { try FeatureCardNode(from: $0) },
        "textBlock": { try TextBlockNode(from: $0) }
    ])
}

nonisolated extension CodingUserInfoKey {
    static let componentRegistry: CodingUserInfoKey = {
        // CodingUserInfoKey.init(rawValue:) only fails for an empty string —
        // never the case for this literal.
        guard let key = CodingUserInfoKey(rawValue: "componentRegistry") else {
            fatalError("CodingUserInfoKey(rawValue:) failed for a non-empty literal")
        }
        return key
    }()
}
