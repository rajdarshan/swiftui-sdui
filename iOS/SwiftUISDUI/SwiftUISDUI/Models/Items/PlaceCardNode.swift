//
//  PlaceCardNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: images M [ImageRef] (min 1), title M, overlayBadge O,
//  subtitle O, linkRow O {text, trailingIcon?, action}, status O {text,
//  detail?, variant}, buttons O [Button] (0-2).
//
//  Cardinality (images min 1, buttons max 2) isn't covered by COMPONENTS.md
//  §10's fallback table explicitly — resolved to: treat a violation as
//  malformed, same path as a missing mandatory prop (decode throws →
//  decodeItem's fallback/skip applies).
//
//  `Decodable` conformance for PlaceCardLinkRow/PlaceCardStatus (declared in
//  Components/PlaceCardView.swift, a Stage-2-reviewed file) is added here
//  via extension rather than editing that file.
//

struct PlaceCardNode: ItemNode, Decodable, Equatable {
    let id: String
    let type: String
    let images: [ImageRef]
    let title: String
    let overlayBadge: Badge?
    let subtitle: String?
    let linkRow: PlaceCardLinkRow?
    let status: PlaceCardStatus?
    let buttons: [ButtonSpec]

    private enum CodingKeys: String, CodingKey {
        case id, type, images, title, overlayBadge, subtitle, linkRow, status, buttons
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)

        let decodedImages = try container.decode([ImageRef].self, forKey: .images)
        guard !decodedImages.isEmpty else {
            throw DecodingError.dataCorruptedError(
                forKey: .images,
                in: container,
                debugDescription: "COMPONENTS.md §8: placeCard.images must have at least 1 element"
            )
        }
        images = decodedImages

        title = try container.decode(String.self, forKey: .title)
        overlayBadge = try container.decodeIfPresent(Badge.self, forKey: .overlayBadge)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        linkRow = try container.decodeIfPresent(PlaceCardLinkRow.self, forKey: .linkRow)
        status = try container.decodeIfPresent(PlaceCardStatus.self, forKey: .status)

        let decodedButtons = try container.decodeIfPresent([ButtonSpec].self, forKey: .buttons) ?? []
        guard decodedButtons.count <= 2 else {
            throw DecodingError.dataCorruptedError(
                forKey: .buttons,
                in: container,
                debugDescription: "COMPONENTS.md §8: placeCard.buttons must have at most 2 elements"
            )
        }
        buttons = decodedButtons
    }
}

extension PlaceCardLinkRow: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey { case text, trailingIcon, action }

    // Equatable can't synthesize `==` from an extension outside the file
    // declaring the struct (Components/PlaceCardView.swift) — hand-written.
    static func == (lhs: PlaceCardLinkRow, rhs: PlaceCardLinkRow) -> Bool {
        lhs.text == rhs.text && lhs.trailingIcon == rhs.trailingIcon && lhs.action == rhs.action
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            text: try container.decode(String.self, forKey: .text),
            trailingIcon: try container.decodeIfPresent(String.self, forKey: .trailingIcon).flatMap(IconToken.resolve),
            action: try container.decode(Action.self, forKey: .action)
        )
    }
}

extension PlaceCardStatus: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey { case text, detail, variant }

    // Equatable can't synthesize `==` from an extension outside the file
    // declaring the struct (Components/PlaceCardView.swift) — hand-written.
    static func == (lhs: PlaceCardStatus, rhs: PlaceCardStatus) -> Bool {
        lhs.text == rhs.text && lhs.detail == rhs.detail && lhs.variant == rhs.variant
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let variantRaw = try container.decodeIfPresent(String.self, forKey: .variant)
        self.init(
            text: try container.decode(String.self, forKey: .text),
            detail: try container.decodeIfPresent(String.self, forKey: .detail),
            variant: variantRaw.flatMap(Badge.Variant.init(rawValue:)) ?? .neutral
        )
    }
}
