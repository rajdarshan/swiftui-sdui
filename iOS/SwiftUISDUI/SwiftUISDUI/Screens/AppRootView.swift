//
//  AppRootView.swift
//  SwiftUISDUI
//
//  @main's WindowGroup content. Renders the LaunchFlow resolved from launch
//  environment directly as the first frame — no NavigationStack, no push
//  transition — so Stage 5's perf harness gets a clean T0 (design_spec.md
//  §3.4). With no launch environment set, falls back to DebugFlowPicker for
//  manual dev use.
//

import SwiftUI

struct AppRootView: View {
    private let launchFlow: LaunchFlow?

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        launchFlow = LaunchFlow.resolve(from: environment)
    }

    var body: some View {
        Group {
            switch launchFlow {
            case .staticHome:
                StaticHomeView()
                    .environment(\.useImageAsset, true)
            case .sdui(let pageId):
                SDUIRootView(pageId: pageId)
            case nil:
                DebugFlowPicker()
            }
        }
    }
}
