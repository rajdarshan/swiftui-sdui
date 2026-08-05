//
//  Action.swift
//  SwiftUISDUI
//
//  Value object. COMPONENTS.md §4.1. `type` is a plain String, not a closed
//  enum — an unknown action type must still render the node and no-op the
//  tap (COMPONENTS.md §10), which a closed enum would fight.
//

nonisolated struct Action {
    let type: String
    let target: String
    let params: [String: String]

    init(type: String, target: String, params: [String: String] = [:]) {
        self.type = type
        self.target = target
        self.params = params
    }
}

nonisolated extension Action: Decodable, Equatable {
    private enum CodingKeys: String, CodingKey { case type, target, params }

    // `type` is never validated against a known set here — COMPONENTS.md
    // §10: an unrecognized action.type still decodes; the node renders and
    // the tap becomes a no-op at dispatch time (Stage 4 ActionHandler).
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            type: try container.decode(String.self, forKey: .type),
            target: try container.decode(String.self, forKey: .target),
            params: try container.decodeIfPresent([String: String].self, forKey: .params) ?? [:]
        )
    }
}
