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
    // @State, not `let`: init can run more than once as SwiftUI reconstructs
    // this struct value (observed under XCUITest's launch/scene lifecycle
    // churn even when body doesn't). @State's initialValue is only honored
    // the first time for a given persistent view identity, so this survives
    // reconstruction the same way SDUIRootView's `_store = State(initialValue:
    // PageStore(...))` does — a plain `let` here silently orphaned marks
    // recorded by an earlier PerformanceMarks instance.
    @State private var performanceMarks: PerformanceMarks

    init(environment: [String: String] = ProcessInfo.processInfo.environment) {
        let launchFlow = LaunchFlow.resolve(from: environment)
        self.launchFlow = launchFlow
        let marks: PerformanceMarks
        switch launchFlow {
        case .staticHome:
            marks = .make(from: environment, variant: "static", pageId: nil)
        case .sdui(let pageId):
            marks = .make(from: environment, variant: "sdui", pageId: pageId)
        case nil:
            marks = .inactive
        }
        _performanceMarks = State(initialValue: marks)
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
        .environment(\.performanceMarks, performanceMarks)
        .overlay(PerformanceProbeOverlay())
    }
}
