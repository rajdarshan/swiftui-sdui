//
//  CarCardNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: image M, title M, price M, action M, overlayBadge O,
//  favorite O {selected, action}, subtitle O, specs O [String], priceSuffix
//  O, priceNote O {text, action?}, trustBadges O [Badge]. `specs` and
//  `trustBadges` default to [] when absent, which is what forces the custom
//  init (synthesis would otherwise throw on the missing key for a
//  non-Optional array).
//
//  `Decodable` conformance for CarCardFavorite/CarCardPriceNote (declared in
//  Components/CarCardView.swift, a Stage-2-reviewed file) is added here via
//  extension rather than editing that file.
//

nonisolated struct CarCardNode: ItemNode, Decodable, Equatable {
    let id: String
    let type: String
    let image: ImageRef
    let title: String
    let price: String
    let action: Action
    let overlayBadge: Badge?
    let favorite: CarCardFavorite?
    let subtitle: String?
    let specs: [String]
    let priceSuffix: String?
    let priceNote: CarCardPriceNote?
    let trustBadges: [Badge]

    private enum CodingKeys: String, CodingKey {
        case id, type, image, title, price, action, overlayBadge, favorite, subtitle
        case specs, priceSuffix, priceNote, trustBadges
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        image = try container.decode(ImageRef.self, forKey: .image)
        title = try container.decode(String.self, forKey: .title)
        price = try container.decode(String.self, forKey: .price)
        action = try container.decode(Action.self, forKey: .action)
        overlayBadge = try container.decodeIfPresent(Badge.self, forKey: .overlayBadge)
        favorite = try container.decodeIfPresent(CarCardFavorite.self, forKey: .favorite)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        specs = try container.decodeIfPresent([String].self, forKey: .specs) ?? []
        priceSuffix = try container.decodeIfPresent(String.self, forKey: .priceSuffix)
        priceNote = try container.decodeIfPresent(CarCardPriceNote.self, forKey: .priceNote)
        trustBadges = try container.decodeIfPresent([Badge].self, forKey: .trustBadges) ?? []
    }
}

// Neither Decodable nor Equatable can synthesize from an extension outside
// the file declaring these structs (Components/CarCardView.swift) — both
// hand-written.

nonisolated extension CarCardFavorite: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey { case selected, action }

    static func == (lhs: CarCardFavorite, rhs: CarCardFavorite) -> Bool {
        lhs.selected == rhs.selected && lhs.action == rhs.action
    }

    // Direct field assignment, not `self.init(...)` — CarCardFavorite's own
    // memberwise init (declared in Components/CarCardView.swift) isn't
    // nonisolated, and that isolation can't be changed from this extension.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selected = try container.decode(Bool.self, forKey: .selected)
        action = try container.decode(Action.self, forKey: .action)
    }
}

nonisolated extension CarCardPriceNote: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey { case text, action }

    static func == (lhs: CarCardPriceNote, rhs: CarCardPriceNote) -> Bool {
        lhs.text == rhs.text && lhs.action == rhs.action
    }

    // Direct field assignment, not `self.init(...)` — CarCardPriceNote's own
    // memberwise init (declared in Components/CarCardView.swift) isn't
    // nonisolated, and that isolation can't be changed from this extension.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        action = try container.decodeIfPresent(Action.self, forKey: .action)
    }
}
