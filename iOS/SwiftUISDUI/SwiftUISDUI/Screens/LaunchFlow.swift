//
//  LaunchFlow.swift
//  SwiftUISDUI
//
//  Resolves the flow AppRootView should render at launch from launch
//  environment variables (the XCUITest launchEnvironment contract Stage 5's
//  perf harness will use to reach a screen with no NavigationLink push).
//

import Foundation

nonisolated enum LaunchFlow: Equatable {
    case staticHome
    case sdui(pageId: String)
}

extension LaunchFlow {
    static let flowKey = "SDUI_LAUNCH_FLOW"
    static let pageIdKey = "SDUI_LAUNCH_PAGE_ID"
    static let staticValue = "static"
    static let sduiValue = "sdui"

    static func resolve(from environment: [String: String]) -> LaunchFlow? {
        switch environment[flowKey] {
        case staticValue:
            return .staticHome
        case sduiValue:
            guard let pageId = environment[pageIdKey], !pageId.isEmpty else { return nil }
            return .sdui(pageId: pageId)
        default:
            return nil
        }
    }
}
