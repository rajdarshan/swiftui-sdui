//
//  TileNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: title M, image O, style O, action M. Every field maps
//  1:1 onto Decodable synthesis (Optional → decodeIfPresent, mandatory →
//  decode/throws) — no custom init needed.
//

struct TileNode: ItemNode, Decodable, Equatable {
    let id: String
    let type: String
    let title: String
    let image: ImageRef?
    let style: Style?
    let action: Action
}
