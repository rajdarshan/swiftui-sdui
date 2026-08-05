//
//  Action.swift
//  SwiftUISDUI
//
//  Value object. COMPONENTS.md §4.1. `type` is a plain String, not a closed
//  enum — an unknown action type must still render the node and no-op the
//  tap (COMPONENTS.md §10), which a closed enum would fight.
//

struct Action {
    let type: String
    let target: String
    let params: [String: String]

    init(type: String, target: String, params: [String: String] = [:]) {
        self.type = type
        self.target = target
        self.params = params
    }
}
