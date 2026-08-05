//
//  DebugLauncherView.swift
//  SwiftUISDUI
//
//  Stage 4's app root (replacing StaticHomeView as @main's direct content).
//  design_spec.md never specifies how a human reaches the SDUI screen versus
//  the static one, so this is a plain debug list, not a designed screen —
//  it keeps every variant reachable at once, which Stage 5's perf harness
//  will need. `useImageAsset` moves here (from SwiftUISDUIApp.swift) so it
//  applies only to the static path — SDUI payloads carry remote ImageRefs,
//  never a local asset name.
//

import SwiftUI

struct DebugLauncherView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Static home") {
                    StaticHomeView()
                        .environment(\.useImageAsset, true)
                        .toolbar(.hidden, for: .navigationBar)
                }
                NavigationLink("SDUI: home_all") {
                    SDUIRootView(pageId: "home_all")
                        .toolbar(.hidden, for: .navigationBar)
                }
                NavigationLink("SDUI: fallback demo") {
                    SDUIRootView(pageId: "home_all_fallback_demo")
                        .toolbar(.hidden, for: .navigationBar)
                }
            }
            .navigationTitle("SwiftUI SDUI")
        }
    }
}
