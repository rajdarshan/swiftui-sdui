//
//  FeatureCardNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: title M, body O, image O, imagePosition O
//  (leading/top, default leading), badge O, footer O {text, trailingIcon?,
//  action}. Wire key is `body`; the Swift property is `bodyText` — same
//  rename FeatureCardView.swift already uses to avoid colliding with the
//  View protocol's own `body`.
//
//  `Decodable`/`Equatable` for FeatureCardFooter (declared in
//  Components/FeatureCardView.swift, a Stage-2-reviewed file) is added here
//  via extension rather than editing that file — neither can synthesize
//  from outside the declaring file, so both are hand-written.
//

nonisolated struct FeatureCardNode: ItemNode, Decodable, Equatable {
    let id: String
    let type: String
    let title: String
    let bodyText: String?
    let image: ImageRef?
    let imagePosition: FeatureCardImagePosition
    let badge: Badge?
    let footer: FeatureCardFooter?
    let imageName: String?

    private enum CodingKeys: String, CodingKey {
        case id, type, title, image, imagePosition, badge, footer, imageName
        case bodyText = "body"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        title = try container.decode(String.self, forKey: .title)
        bodyText = try container.decodeIfPresent(String.self, forKey: .bodyText)
        image = try container.decodeIfPresent(ImageRef.self, forKey: .image)
        let positionRaw = try container.decodeIfPresent(String.self, forKey: .imagePosition)
        imagePosition = positionRaw.flatMap(FeatureCardImagePosition.init(rawValue:)) ?? .leading
        badge = try container.decodeIfPresent(Badge.self, forKey: .badge)
        footer = try container.decodeIfPresent(FeatureCardFooter.self, forKey: .footer)
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
    }
}

nonisolated extension FeatureCardFooter: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey { case text, trailingIcon, action }

    static func == (lhs: FeatureCardFooter, rhs: FeatureCardFooter) -> Bool {
        lhs.text == rhs.text && lhs.trailingIcon == rhs.trailingIcon && lhs.action == rhs.action
    }

    // Direct field assignment, not `self.init(...)` — FeatureCardFooter's own
    // memberwise init (declared in Components/FeatureCardView.swift) isn't
    // nonisolated, and that isolation can't be changed from this extension.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        trailingIcon = try container.decodeIfPresent(String.self, forKey: .trailingIcon).flatMap(IconToken.resolve)
        action = try container.decode(Action.self, forKey: .action)
    }
}
