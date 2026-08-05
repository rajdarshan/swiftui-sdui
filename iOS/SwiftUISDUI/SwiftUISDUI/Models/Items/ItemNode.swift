//
//  ItemNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §8: every item carries `id` (M) and `type` (M, registry
//  key). `ID == String` keeps `any ItemNode` usable directly wherever
//  SwiftUI needs Identifiable (RailView/GridView item arrays).
//

nonisolated protocol ItemNode: Identifiable where ID == String {
    var id: String { get }
    var type: String { get }
}
