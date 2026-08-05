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

    init(pageId: String, source: PayloadSource = BundlePayloadSource()) {
        self.source = source
        _pageId = State(initialValue: pageId)
        _store = State(initialValue: PageStore(pageId: pageId, source: source))
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
