//
//  ActionDispatchTests.swift
//  SwiftUISDUITests
//
//  Executed tests for ActionDispatch.classify (design_spec.md §6.1/§6.2,
//  COMPONENTS.md §4.1/§10). Pure logic, no SwiftUI dependency.
//

import Foundation
@testable import SwiftUISDUI
import Testing

struct ActionDispatchTests {
    private let knownPageIds: Set<String> = ["home_all", "home_loans"]

    @Test
    func navigateToAKnownPageIdLoadsThatPage() {
        let action = Action(type: "navigate", target: "home_loans")
        #expect(ActionDispatch.classify(action, knownPageIds: knownPageIds) == .loadPage("home_loans"))
    }

    @Test
    func navigateToAnUnknownTargetShowsDebugScreen() {
        let action = Action(type: "navigate", target: "car_detail")
        #expect(ActionDispatch.classify(action, knownPageIds: knownPageIds) == .showDebug(action))
    }

    @Test
    func openSheetAlwaysShowsDebugScreen() {
        let action = Action(type: "openSheet", target: "city_picker")
        #expect(ActionDispatch.classify(action, knownPageIds: knownPageIds) == .showDebug(action))
    }

    @Test
    func toggleReturnsTheEntityId() {
        let action = Action(type: "toggle", target: "car_10021")
        #expect(ActionDispatch.classify(action, knownPageIds: knownPageIds) == .toggle("car_10021"))
    }

    @Test
    func callBuildsATelURL() {
        let action = Action(type: "call", target: "+918001234567")
        #expect(ActionDispatch.classify(action, knownPageIds: knownPageIds) == .openSystemURL(URL(string: "tel:+918001234567")!))
    }

    @Test
    func openUrlUsesTheTargetVerbatim() {
        let action = Action(type: "openUrl", target: "https://example.com/promo")
        #expect(
            ActionDispatch.classify(action, knownPageIds: knownPageIds)
                == .openSystemURL(URL(string: "https://example.com/promo")!)
        )
    }

    @Test
    func openMapsBuildsAURLFromLatLngParams() {
        let action = Action(type: "openMaps", target: "showroom_101", params: ["lat": "12.9767", "lng": "77.5713"])
        #expect(
            ActionDispatch.classify(action, knownPageIds: knownPageIds)
                == .openSystemURL(URL(string: "http://maps.apple.com/?ll=12.9767,77.5713")!)
        )
    }

    @Test
    func openMapsWithoutLatLngParamsIsANoop() {
        let action = Action(type: "openMaps", target: "showroom_101")
        #expect(ActionDispatch.classify(action, knownPageIds: knownPageIds) == .noop)
    }

    @Test
    func searchIsANoop() {
        let action = Action(type: "search", target: "search")
        #expect(ActionDispatch.classify(action, knownPageIds: knownPageIds) == .noop)
    }

    @Test
    func selectIsANoopSinceItIsReserved() {
        let action = Action(type: "select", target: "used_cars_rail")
        #expect(ActionDispatch.classify(action, knownPageIds: knownPageIds) == .noop)
    }

    @Test
    func unrecognizedActionTypeIsANoop() {
        let action = Action(type: "levitate", target: "anything")
        #expect(ActionDispatch.classify(action, knownPageIds: knownPageIds) == .noop)
    }
}
