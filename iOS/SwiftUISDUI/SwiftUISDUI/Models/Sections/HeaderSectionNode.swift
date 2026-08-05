//
//  HeaderSectionNode.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §9: `type: "header"`. First section if present; pinned,
//  collapse is client-owned. `search` M {placeholders[], rotateMs?,
//  action}, `tabs` M {items[], selectedId}, `location` O {text, action},
//  `avatar` O {image, action}. Unlike the other 5 containers, header has no
//  `header`/`style`/`filter` fields of its own (§6's common table doesn't
//  apply here — a header section doesn't recursively have a header).
//
//  Deliberately independent of Components/HeaderView.swift's
//  HeaderSearchData/HeaderTab/etc. — those are Stage-2 leaf-view params,
//  not one of the six shared value objects Stage 3 reuses as-is, and
//  HeaderSearchData has no `rotateMs` field at all. Bridging this node to
//  those view params is a Stage 4 concern.
//

nonisolated struct HeaderSectionNode: Decodable, Equatable {
    let id: String
    let search: HeaderSearchNode
    let tabs: HeaderTabsNode
    let location: HeaderLocationNode?
    let avatar: HeaderAvatarNode?
}

nonisolated struct HeaderSearchNode: Decodable, Equatable {
    let placeholders: [String]
    let rotateMs: Int?
    let action: Action
}

nonisolated struct HeaderTabsNode: Decodable, Equatable {
    let items: [HeaderTabNode]
    let selectedId: String
}

nonisolated struct HeaderTabNode: Decodable, Equatable, Identifiable {
    let id: String
    let label: String
    let icon: String?
    let action: Action

    private enum CodingKeys: String, CodingKey { case id, label, icon, action }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        icon = try container.decodeIfPresent(String.self, forKey: .icon).flatMap(IconToken.resolve)
        action = try container.decode(Action.self, forKey: .action)
    }
}

nonisolated struct HeaderLocationNode: Decodable, Equatable {
    let text: String
    let action: Action
}

nonisolated struct HeaderAvatarNode: Decodable, Equatable {
    let image: ImageRef
    let action: Action
}
