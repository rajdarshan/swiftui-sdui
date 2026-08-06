//
//  SDUIRootView.swift
//  SwiftUISDUI
//
//  design_spec.md §3.1: owns which `pageId` is currently loaded and the
//  `PageStore` for it — "one PageStore per pageId," so switching pages
//  constructs a new instance rather than mutating the old one's pageId
//  in place. A header tab's `navigate` action, once ActionDispatch resolves
//  it to `.loadPage(pageId)` (COMPONENTS.md §6.1/design_spec.md §6.1),
//  arrives here via SDUIPageView's `onNavigateToPage` callback.
//
//  `knownPageIds` is loaded once from the manifest and handed down to every
//  SDUIPageView instance built here — it's what lets ActionDispatch tell a
//  tab's real page-load navigate apart from every other navigate/openSheet
//  action that resolves to DebugActionScreen.
//

import SwiftUI

struct SDUIRootView: View {
    let source: PayloadSource

    @State private var pageId: String
    @State private var store: PageStore
    @State private var knownPageIds: Set<String> = []
    @State private var hasReportedLaunchMetrics = false
    @Environment(\.performanceMarks) private var marks

    init(pageId: String, source: PayloadSource = BundlePayloadSource()) {
        let t0 = ContinuousClock.now
        self.source = source
        _pageId = State(initialValue: pageId)
        _store = State(initialValue: PageStore(pageId: pageId, source: source, t0: t0))
    }

    var body: some View {
        Group {
            switch store.loadState {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .failed:
                Text("Failed to load \(pageId)")
                    .foregroundStyle(Palette.textDanger)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded:
                SDUIPageView(store: store, knownPageIds: knownPageIds, onNavigateToPage: navigate(to:))
            }
        }
        .task(id: pageId) {
            await store.load()
            // Reported once: PageStore.load()'s loadState = .loaded assignment
            // and this check run in the same synchronous continuation with no
            // further await between them, so T0/T1 are always recorded before
            // SDUIPageView's body (T2) ever runs. Guarded so in-app navigation
            // (which builds a fresh, un-t0'd PageStore via navigate(to:))
            // never re-reports after the initial launch-time load.
            if !hasReportedLaunchMetrics, let t0 = store.t0, let t1 = store.t1 {
                hasReportedLaunchMetrics = true
                marks.recordLoad(t0: t0, t1: t1)
            }
        }
        .task {
            if let manifest = try? await source.loadManifest() {
                knownPageIds = Set(manifest.payloads.map(\.pageId))
            }
        }
    }

    private func navigate(to newPageId: String) {
        guard newPageId != pageId else { return }
        pageId = newPageId
        store = PageStore(pageId: newPageId, source: source)
    }
}
