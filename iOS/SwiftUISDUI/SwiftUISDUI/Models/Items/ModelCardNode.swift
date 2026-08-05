//
//  ModelCardNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: title M, image M, subtitle O, watermark O, style O,
//  action M. Straight Decodable synthesis — image being mandatory (not
//  Optional) is what makes it throw when absent, same fallback path as an
//  unknown type.
//

nonisolated struct ModelCardNode: ItemNode, Decodable, Equatable {
    let id: String
    let type: String
    let title: String
    let image: ImageRef
    let subtitle: String?
    let watermark: String?
    let style: Style?
    let action: Action
}
