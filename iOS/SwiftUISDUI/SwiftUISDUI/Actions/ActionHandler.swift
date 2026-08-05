//
//  ActionHandler.swift
//  SwiftUISDUI
//
//  design_spec.md §3.2 rule 4: nodes carry Action values, never closures;
//  ActionHandler is injected via @Environment. Default value is a no-op, so
//  any leaf view that dispatches its tap through this environment key stays
//  inert wherever no handler is injected — StaticHomeView never injects one
//  (design_spec.md §5), with zero special-casing needed at the leaf-view
//  call sites.
//

import SwiftUI

struct ActionHandler {
    let handle: (Action) -> Void
}

private struct ActionHandlerKey: EnvironmentKey {
    static let defaultValue = ActionHandler { _ in }
}

extension EnvironmentValues {
    var actionHandler: ActionHandler {
        get { self[ActionHandlerKey.self] }
        set { self[ActionHandlerKey.self] = newValue }
    }
}
