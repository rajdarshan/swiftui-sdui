//
//  TextBlockNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: title M, subtitle O, style O. Every field maps 1:1
//  onto Decodable synthesis — no custom init needed.
//

nonisolated struct TextBlockNode: ItemNode, Decodable, Equatable {
    let id: String
    let type: String
    let title: String
    let subtitle: String?
    let style: Style?
}
