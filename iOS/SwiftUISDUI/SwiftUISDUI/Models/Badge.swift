//
//  Badge.swift
//  SwiftUISDUI
//
//  Value object. COMPONENTS.md §4.3. `icon` is an already-resolved SF Symbol
//  name (via IconToken), not a token string.
//

nonisolated struct Badge {
    enum Variant: String {
        case neutral, accent, success, warning, danger
    }

    let text: String
    let icon: String?
    let variant: Variant

    init(text: String, icon: String? = nil, variant: Variant = .neutral) {
        self.text = text
        self.icon = icon
        self.variant = variant
    }
}

nonisolated extension Badge: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey { case text, icon, variant }

    // COMPONENTS.md §10: unknown icon token → icon omitted, text stays.
    // COMPONENTS.md §2.1: an unrecognized enum value on an optional field
    // degrades the same way an older client would skip a case it doesn't
    // know — falls back to the stated default (`neutral`).
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let text = try container.decode(String.self, forKey: .text)
        let icon = try container.decodeIfPresent(String.self, forKey: .icon).flatMap(IconToken.resolve)
        let variantRaw = try container.decodeIfPresent(String.self, forKey: .variant)
        let variant = variantRaw.flatMap(Variant.init(rawValue:)) ?? .neutral
        self.init(text: text, icon: icon, variant: variant)
    }
}
