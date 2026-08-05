//
//  ActionDispatch.swift
//  SwiftUISDUI
//
//  design_spec.md §6.1/§6.2, COMPONENTS.md §4.1/§10. Pure classification of
//  an `Action` into what should happen, with no SwiftUI dependency so it's
//  fully unit testable (design_spec.md's "executed tests" bucket).
//
//  The `navigate`-vs-`DebugActionScreen` split is derived from the actual
//  home_all.json payload, not invented: every header tab's `navigate.target`
//  is literally one of the manifest's `pageId`s, while every other
//  navigate/openSheet action in the payload targets something that is not a
//  pageId ("profile", "listing", "car_detail", ...). That reconciles
//  design_spec.md §6.1 ("tapping a tab loads that pageId") with §6.2 ("all
//  navigate/openSheet actions resolve to DebugActionScreen") as one rule:
//  `navigate` whose target is a known pageId loads that page for real;
//  every other `navigate`/`openSheet` shows DebugActionScreen.
//
//  `openMaps`'s `params` keys ("lat"/"lng") are likewise confirmed against
//  the actual payload data, not guessed. `call`/`openUrl` build the URL the
//  system handler needs (design_spec.md §6.2: "invoke the system handler").
//  `search`/`select`/anything unrecognized is `.noop` — the node still
//  renders (COMPONENTS.md §4.1/§10), the tap just does nothing.
//

import Foundation

nonisolated enum ActionOutcome: Equatable {
    case loadPage(String)
    case showDebug(Action)
    case toggle(String)
    case openSystemURL(URL)
    case noop
}

nonisolated enum ActionDispatch {
    static func classify(_ action: Action, knownPageIds: Set<String>) -> ActionOutcome {
        switch action.type {
        case "navigate":
            if knownPageIds.contains(action.target) {
                .loadPage(action.target)
            } else {
                .showDebug(action)
            }
        case "openSheet":
            .showDebug(action)
        case "toggle":
            .toggle(action.target)
        case "call":
            callOutcome(phoneNumber: action.target)
        case "openUrl":
            openURLOutcome(target: action.target)
        case "openMaps":
            openMapsOutcome(params: action.params)
        default:
            .noop
        }
    }

    private static func callOutcome(phoneNumber: String) -> ActionOutcome {
        URL(string: "tel:\(phoneNumber)").map(ActionOutcome.openSystemURL) ?? .noop
    }

    private static func openURLOutcome(target: String) -> ActionOutcome {
        URL(string: target).map(ActionOutcome.openSystemURL) ?? .noop
    }

    private static func openMapsOutcome(params: [String: String]) -> ActionOutcome {
        guard let lat = params["lat"], let lng = params["lng"],
              let url = URL(string: "http://maps.apple.com/?ll=\(lat),\(lng)") else {
            return .noop
        }
        return .openSystemURL(url)
    }
}
