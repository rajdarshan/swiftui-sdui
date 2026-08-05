//
//  PageStore.swift
//  SwiftUISDUI
//
//  design_spec.md §3.1: "PageStore (@Observable, @MainActor) one per pageId
//  — holds [SectionNode], filter selections, load state." One instance per
//  pageId; switching pages means the owning view (SDUIRootView) constructs a
//  new PageStore rather than mutating this one's pageId in place.
//
//  `filterSelections` is keyed by section id (COMPONENTS.md §7: "Selection
//  state is local to the section") — stored here, not as view @State, so a
//  chip choice survives SDUIPageView's section views being rebuilt.
//
//  `toggledIds` backs carCard's `favorite` toggle action (COMPONENTS.md
//  §4.1: toggle "Flip a boolean (wishlist)"). A card's effective `selected`
//  state is computed at the ComponentRegistry.itemViews call site via
//  ItemRenderContext, never stored on the node itself — nodes stay immutable
//  value types (design_spec.md §3.2 rule 1).
//

import Observation

enum PageLoadState: Equatable {
    case loading
    case loaded
    case failed
}

@Observable
@MainActor
final class PageStore {
    let pageId: String
    private let source: PayloadSource

    private(set) var sections: [SectionNode] = []
    private(set) var loadState: PageLoadState = .loading
    var filterSelections: [String: String] = [:]
    private(set) var toggledIds: Set<String> = []

    init(pageId: String, source: PayloadSource) {
        self.pageId = pageId
        self.source = source
    }

    func load() async {
        loadState = .loading
        do {
            let envelope = try await source.loadPage(pageId: pageId)
            sections = envelope.sections
            loadState = .loaded
        } catch {
            print("PageStore Laod error: \(error)")
            loadState = .failed
        }
    }

    func toggle(_ id: String) {
        if toggledIds.contains(id) {
            toggledIds.remove(id)
        } else {
            toggledIds.insert(id)
        }
    }

    func selectedChipId(forSection sectionId: String, default defaultChipId: String) -> String {
        filterSelections[sectionId] ?? defaultChipId
    }

    func selectChip(_ chipId: String, forSection sectionId: String) {
        filterSelections[sectionId] = chipId
    }
}
