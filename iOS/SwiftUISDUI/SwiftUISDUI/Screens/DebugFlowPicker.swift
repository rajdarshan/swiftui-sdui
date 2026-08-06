//
//  DebugFlowPicker.swift
//  SwiftUISDUI
//
//  AppRootView's fallback when LaunchFlow.resolve(from:) finds no launch
//  environment (i.e. a normal, non-harness launch) — a plain debug list
//  for a human to reach either variant. design_spec.md never specifies a
//  designed picker screen, so this stays a stopgap, not a designed one.
//  `useImageAsset` applies only to the static path — SDUI payloads carry
//  remote ImageRefs, never a local asset name.
//

import SwiftUI

struct DebugFlowPicker: View {
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
