//
//  PromoCardNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: title M, image O, eyebrow O, subtitle O, logos O
//  [ImageRef], button O, style O. `logos` defaults to [] when absent, which
//  forces the custom init (synthesis would otherwise throw on the missing
//  key for a non-Optional array).
//

struct PromoCardNode: ItemNode, Decodable, Equatable {
    let id: String
    let type: String
    let title: String
    let image: ImageRef?
    let eyebrow: String?
    let subtitle: String?
    let logos: [ImageRef]
    let button: ButtonSpec?
    let style: Style?

    private enum CodingKeys: String, CodingKey {
        case id, type, title, image, eyebrow, subtitle, logos, button, style
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        title = try container.decode(String.self, forKey: .title)
        image = try container.decodeIfPresent(ImageRef.self, forKey: .image)
        eyebrow = try container.decodeIfPresent(String.self, forKey: .eyebrow)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        logos = try container.decodeIfPresent([ImageRef].self, forKey: .logos) ?? []
        button = try container.decodeIfPresent(ButtonSpec.self, forKey: .button)
        style = try container.decodeIfPresent(Style.self, forKey: .style)
    }
}
