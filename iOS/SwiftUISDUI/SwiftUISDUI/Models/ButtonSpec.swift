//
//  ButtonSpec.swift
//  SwiftUISDUI
//
//  Value object. COMPONENTS.md §4.4, calls it "Button" — renamed here to
//  avoid colliding with SwiftUI.Button.
//

struct ButtonSpec {
    enum Variant: String {
        case filled, outline, ghost
    }

    let text: String
    let action: Action
    let variant: Variant
    let leadingIcon: String?

    init(text: String, action: Action, variant: Variant = .filled, leadingIcon: String? = nil) {
        self.text = text
        self.action = action
        self.variant = variant
        self.leadingIcon = leadingIcon
    }
}

extension ButtonSpec: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey { case text, action, variant, leadingIcon }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let text = try container.decode(String.self, forKey: .text)
        let action = try container.decode(Action.self, forKey: .action)
        let variantRaw = try container.decodeIfPresent(String.self, forKey: .variant)
        let variant = variantRaw.flatMap(Variant.init(rawValue:)) ?? .filled
        let leadingIcon = try container.decodeIfPresent(String.self, forKey: .leadingIcon).flatMap(IconToken.resolve)
        self.init(text: text, action: action, variant: variant, leadingIcon: leadingIcon)
    }
}
