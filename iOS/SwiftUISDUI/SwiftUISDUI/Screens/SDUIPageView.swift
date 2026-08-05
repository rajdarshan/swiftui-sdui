//
//  SDUIPageView.swift
//  SwiftUISDUI
//
//  design_spec.md §3.1: PageStore -> SDUIPageView -> ComponentRegistry (view
//  closures), with ActionHandler injected via @Environment. Mirrors
//  StaticHomeView's scroll container (ScrollView + LazyVStack(spacing: 24),
//  onScrollGeometryChange for collapseProgress, .measuringAvailableWidth,
//  design_spec.md §4.1/§4.2) but drives content from `store.sections`
//  through the registry instead of hardcoded static data. Duplicated rather
//  than extracted from StaticHomeView — that file is Stage-2, human-reviewed
//  (design_spec.md §5), and this stays the smallest change for this unit of
//  work.
//
//  The header section (COMPONENTS.md §9, "First section if present. Pinned")
//  is pulled out of `store.sections` and rendered as the fixed overlay, same
//  as StaticHomeView; every other section renders in scroll order via a
//  plain `switch`, mirroring SectionDecoding.swift's decode-side `switch`
//  rather than a second registry dictionary (containers are a fixed set of
//  5 + header, not an extension point — SectionNode.swift's own comment).
//
//  Filter chip selection (COMPONENTS.md §7) reads/writes
//  PageStore.filterSelections, keyed by section id — "local to the section"
//  semantically, but held on PageStore so it survives section views being
//  rebuilt (design_spec.md §3.1's architecture diagram: "PageStore ... holds
//  filter selections").
//
//  `.single`'s outer horizontal padding is applied per item type, matching
//  StaticHomeView's own per-instance choices exactly: promoCard/featureCard
//  get page-margin padding at the call site (their leaf views don't add it
//  internally); textBlock does not (TextBlockView already pads itself).
//

import SwiftUI
import UIKit

private struct DebugActionPresentation: Identifiable {
    let id = UUID()
    let action: Action
}

/// `RailView`/`GridView`/`CarouselView` all require `Item: Identifiable`.
/// `any ItemNode` (an existential) doesn't automatically satisfy that
/// generic constraint even though every conformer is itself Identifiable —
/// this wrapper is the type-erasure boundary that makes it concrete.
private struct AnyItemNode: Identifiable {
    let id: String
    let node: any ItemNode
}

private func wrap(_ items: [any ItemNode]) -> [AnyItemNode] {
    items.map { AnyItemNode(id: $0.id, node: $0) }
}

struct SDUIPageView: View {
    var store: PageStore
    let knownPageIds: Set<String>
    let onNavigateToPage: (String) -> Void

    @State private var collapseProgress: CGFloat = 0
    @State private var availableWidth: CGFloat = 0
    @State private var debugPresentation: DebugActionPresentation?

    private let collapseScrollRange: CGFloat = 250 - 151

    private var headerSection: HeaderSectionNode? {
        for section in store.sections {
            if case .header(let node) = section { return node }
        }
        return nil
    }

    private var contentSections: [SectionNode] {
        store.sections.filter {
            if case .header = $0 { return false }
            return true
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(spacing: Spacing.sectionGap) {
                    if headerSection != nil {
                        Color(Palette.brandPrimary).frame(height: 250)
                    }
                    ForEach(contentSections, id: \.id) { section in
                        sectionView(for: section)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.y }, action: updateCollapseProgress)
            .environment(\.availableWidth, availableWidth)

            if let headerSection {
                HeaderView(
                    location: headerSection.location.map { HeaderLocationData(text: $0.text, action: $0.action) },
                    avatar: headerSection.avatar.map { HeaderAvatarData(image: $0.image, action: $0.action, imageName: "person") },
                    search: HeaderSearchData(placeholders: headerSection.search.placeholders, action: headerSection.search.action),
                    tabs: headerSection.tabs.items.map {
                        // COMPONENTS.md §10: unknown/absent icon token -> client default.
                        HeaderTab(id: $0.id, label: $0.label, icon: $0.icon ?? IconToken.grid, action: $0.action)
                    },
                    selectedTabId: headerSection.tabs.selectedId,
                    collapseProgress: collapseProgress
                )
                .ignoresSafeArea(edges: .top)
            }
        }
        .measuringAvailableWidth(into: $availableWidth)
        .environment(\.actionHandler, ActionHandler(handle: handle))
        .sheet(item: $debugPresentation) { presentation in
            DebugActionScreen(action: presentation.action)
        }
    }

    private func updateCollapseProgress(oldValue: CGFloat, newValue: CGFloat) {
        collapseProgress = min(max(newValue / collapseScrollRange, 0), 1)
    }

    @ViewBuilder
    private func sectionView(for section: SectionNode) -> some View {
        switch section {
        case .header:
            EmptyView() // rendered separately as the pinned overlay; unreachable via contentSections
        case .rail(let rail):
            SectionContainer(header: rail.header, style: rail.style) {
                filterableContent(filter: rail.filter, plainItems: rail.items, sectionId: rail.id) { items in
                    RailView(items: wrap(items), itemWidth: rail.itemWidth, snap: rail.snap) { wrapped in itemView(for: wrapped.node) }
                }
            }
        case .grid(let grid):
            SectionContainer(header: grid.header, style: grid.style) {
                filterableContent(filter: grid.filter, plainItems: grid.items, sectionId: grid.id) { items in
                    GridView(items: wrap(items), columns: grid.columns) { wrapped in itemView(for: wrapped.node) }
                }
            }
        case .carousel(let carousel):
            SectionContainer(header: carousel.header, style: carousel.style) {
                CarouselView(items: wrap(carousel.items), loop: carousel.loop, peek: carousel.peek) { wrapped in itemView(for: wrapped.node) }
            }
        case .list:
            // COMPONENTS.md §13: "unused on this screen" — no container view
            // exists for it (Stage 2 never built one). Decodes fine; simply
            // doesn't render rather than inventing an unrequested component.
            EmptyView()
        case .single(let single):
            SectionContainer(header: single.header, style: single.style) {
                singleItemView(for: single.item)
            }
        }
    }

    @ViewBuilder
    private func filterableContent(
        filter: FilterNode?,
        plainItems: [any ItemNode]?,
        sectionId: String,
        @ViewBuilder content: @escaping ([any ItemNode]) -> some View
    ) -> some View {
        if let filter {
            VStack(alignment: .leading, spacing: Spacing.sectionHeaderToContent) {
                chipsRow(filter: filter, sectionId: sectionId)
                content(selectedChipItems(filter: filter, sectionId: sectionId))
            }
        } else {
            content(plainItems ?? [])
        }
    }

    private func selectedChipItems(filter: FilterNode, sectionId: String) -> [any ItemNode] {
        let selectedId = store.selectedChipId(forSection: sectionId, default: filter.defaultChipId)
        let chip = filter.chips.first { $0.id == selectedId } ?? filter.defaultChip
        return chip.items
    }

    private func chipsRow(filter: FilterNode, sectionId: String) -> some View {
        let selectedId = store.selectedChipId(forSection: sectionId, default: filter.defaultChipId)
        return HStack(spacing: Spacing.sectionHeaderToContent) {
            ForEach(filter.chips, id: \.id) { chip in
                let selected = chip.id == selectedId
                Text(chip.label)
                    .font(Typography.link)
                    .foregroundStyle(selected ? Palette.brandPrimary : Palette.textSecondary)
                    .padding(.horizontal, Spacing.cardPadding)
                    .frame(height: 36)
                    .background(Palette.surfaceDefault, in: Capsule())
                    .overlay(Capsule().strokeBorder(selected ? Palette.brandPrimary : Palette.textSecondary.opacity(0.3)))
                    .onTapGesture { store.selectChip(chip.id, forSection: sectionId) }
            }
        }
        .padding(.horizontal, Spacing.pageMargin)
    }

    @ViewBuilder
    private func singleItemView(for item: any ItemNode) -> some View {
        if item.type == "textBlock" {
            itemView(for: item)
        } else {
            itemView(for: item)
                .padding(.horizontal, Spacing.pageMargin)
        }
    }

    private func itemView(for item: any ItemNode) -> AnyView {
        let context = ItemRenderContext(toggledIds: store.toggledIds)
        guard let build = ComponentRegistry.shared.itemViews[item.type] else {
            return AnyView(EmptyView())
        }
        return build(item, context)
    }

    private func handle(_ action: Action) {
        switch ActionDispatch.classify(action, knownPageIds: knownPageIds) {
        case .loadPage(let pageId):
            onNavigateToPage(pageId)
        case .showDebug(let debugAction):
            debugPresentation = DebugActionPresentation(action: debugAction)
        case .toggle(let id):
            store.toggle(id)
        case .openSystemURL(let url):
            UIApplication.shared.open(url)
        case .noop:
            break
        }
    }
}
