//
//  LaunchFlowTests.swift
//  SwiftUISDUITests
//
//  Executed tests for LaunchFlow.resolve(from:). Pure logic, no SwiftUI
//  dependency.
//

@testable import SwiftUISDUI
import Testing

struct LaunchFlowTests {
    @Test
    func emptyEnvironmentResolvesToNil() {
        #expect(LaunchFlow.resolve(from: [:]) == nil)
    }

    @Test
    func missingFlowKeyResolvesToNil() {
        #expect(LaunchFlow.resolve(from: ["SOME_OTHER_KEY": "value"]) == nil)
    }

    @Test
    func staticFlowValueResolvesToStaticHome() {
        #expect(LaunchFlow.resolve(from: ["SDUI_LAUNCH_FLOW": "static"]) == .staticHome)
    }

    @Test
    func staticFlowIgnoresAPresentPageIdKey() {
        let environment = ["SDUI_LAUNCH_FLOW": "static", "SDUI_LAUNCH_PAGE_ID": "home_all"]
        #expect(LaunchFlow.resolve(from: environment) == .staticHome)
    }

    @Test
    func sduiFlowWithPageIdResolvesToThatPageId() {
        let environment = ["SDUI_LAUNCH_FLOW": "sdui", "SDUI_LAUNCH_PAGE_ID": "home_all"]
        #expect(LaunchFlow.resolve(from: environment) == .sdui(pageId: "home_all"))
    }

    @Test
    func sduiFlowWithoutPageIdKeyResolvesToNil() {
        #expect(LaunchFlow.resolve(from: ["SDUI_LAUNCH_FLOW": "sdui"]) == nil)
    }

    @Test
    func sduiFlowWithEmptyPageIdResolvesToNil() {
        let environment = ["SDUI_LAUNCH_FLOW": "sdui", "SDUI_LAUNCH_PAGE_ID": ""]
        #expect(LaunchFlow.resolve(from: environment) == nil)
    }

    @Test
    func unrecognizedFlowValueResolvesToNil() {
        #expect(LaunchFlow.resolve(from: ["SDUI_LAUNCH_FLOW": "levitate"]) == nil)
    }

    @Test(arguments: ["home_all", "home_all_fallback_demo", "some_future_page"])
    func sduiFlowAcceptsAnyPageId(_ pageId: String) {
        let environment = ["SDUI_LAUNCH_FLOW": "sdui", "SDUI_LAUNCH_PAGE_ID": pageId]
        #expect(LaunchFlow.resolve(from: environment) == .sdui(pageId: pageId))
    }
}
