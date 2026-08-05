//
//  IconTileNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: label M, image M, imageShape O (circle/arch/square),
//  action M. `imageShape`'s absent-default is `.square`, matching
//  IconTileView's own existing Swift-level default (Components/IconTileView.swift).
//  COMPONENTS.md §2.1: an unrecognized value degrades the same way — falls
//  back to that default rather than throwing the whole item away.
//

struct IconTileNode: ItemNode, Decodable, Equatable {
    let id: String
    let type: String
    let label: String
    let image: ImageRef
    let imageShape: IconTileImageShape
    let action: Action

    private enum CodingKeys: String, CodingKey { case id, type, label, image, imageShape, action }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        label = try container.decode(String.self, forKey: .label)
        image = try container.decode(ImageRef.self, forKey: .image)
        let shapeRaw = try container.decodeIfPresent(String.self, forKey: .imageShape)
        imageShape = shapeRaw.flatMap(IconTileImageShape.init(rawValue:)) ?? .square
        action = try container.decode(Action.self, forKey: .action)
    }
}
