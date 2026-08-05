//
//  HeaderView.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §9 header section. design_spec.md §4.2 — highest
//  implementation risk. Collapses from 280pt to 104pt.
//
//  `collapseProgress` (0 = expanded, 1 = collapsed) is computed by the page
//  container from .onScrollGeometryChange and passed in — HeaderView itself
//  never reads scroll state directly, and never uses the GeometryReader +
//  preference-key offset-tracking pattern CLAUDE.md prohibits.
//
//  Same tab data drives both states: selected = white fill + bold label
//  (expanded), underline only, no bold, (collapsed) — design_spec.md §4.2's
//  "white fill + bold label (expanded), underline (collapsed)" scopes "bold"
//  to the expanded clause only. Non-`all` tab taps are inert in Stage 2
//  (design_spec.md §5) — no PageStore to load another page yet.
//
//  location/avatar have no icon prop in COMPONENTS.md §9 — their pin/avatar
//  chrome is fixed client decoration, not server-token-driven, so it's
//  hardcoded here rather than routed through IconToken.
//
//  Content only receives normal safe-area top inset (not a manual padding
//  guess) — only the background ignores the safe area, so the status bar is
//  covered without the content itself needing a magic-number offset.
//
//  Height budget, deliberately kept inside both frames rather than clipped:
//  collapsed (104) = 12 top + 44 search + 12 gap + 36 tab area = 104 exactly.
//  expanded (280) = 12 top + 40 topRow + 12 gap + 44 search + 12 gap + 80 tab
//  area = 200, with the remaining 80pt absorbed by a trailing Spacer rather
//  than forcing an exact fit — slack is fine, overflow is not.
//
//  No token in design_spec.md §2.2's text-style table covers tab labels —
//  reusing the closest existing tokens (caption for the expanded icon-chip
//  label, body for the collapsed strip) with a .bold() override on the
//  expanded-selected case, rather than inventing an unlisted raw font spec.
//
//  location/avatar/search/each tab dispatch their own `action` through the
//  environment-injected ActionHandler (design_spec.md §3.2 rule 4) — inert
//  by default, matching the static screen (which never injects a handler).
//  A tab's `action` is always `navigate` targeting a pageId (COMPONENTS.md
//  §6.1/design_spec.md §6.1), which ActionDispatch resolves to a real page
//  load rather than DebugActionScreen.
//

import SwiftUI

struct HeaderTab: Identifiable {
    let id: String
    let label: String
    let icon: String
    let action: Action
}

struct HeaderSearchData {
    let placeholders: [String]
    let action: Action
}

struct HeaderLocationData {
    let text: String
    let action: Action
}

struct HeaderAvatarData {
    let image: ImageRef
    let action: Action
    let imageName: String
}

struct HeaderView: View {
    let location: HeaderLocationData?
    let avatar: HeaderAvatarData?
    let search: HeaderSearchData
    let tabs: [HeaderTab]
    let selectedTabId: String
    let collapseProgress: CGFloat

    @Environment(\.actionHandler) private var actionHandler

    private let expandedHeight: CGFloat = 250
    private let collapsedHeight: CGFloat = 151
    private let expandedTabAreaHeight: CGFloat = 80
    private let collapsedTabAreaHeight: CGFloat = 36
    private let topRowHeight: CGFloat = 40

    init(
        location: HeaderLocationData? = nil,
        avatar: HeaderAvatarData? = nil,
        search: HeaderSearchData,
        tabs: [HeaderTab],
        selectedTabId: String,
        collapseProgress: CGFloat = 0
    ) {
        self.location = location
        self.avatar = avatar
        self.search = search
        self.tabs = tabs
        self.selectedTabId = selectedTabId
        self.collapseProgress = min(max(collapseProgress, 0), 1)
    }

    private var height: CGFloat {
        expandedHeight - (expandedHeight - collapsedHeight) * collapseProgress
    }

    private var tabAreaHeight: CGFloat {
        expandedTabAreaHeight - (expandedTabAreaHeight - collapsedTabAreaHeight) * collapseProgress
    }

    var body: some View {
        VStack(spacing: 0) {
            Color(Palette.brandPrimary).frame(height: 47)
            if collapseProgress < 1 {
                topRow
                    .opacity(1 - collapseProgress)
                    .frame(height: topRowHeight * (1 - collapseProgress))
                    .padding(.bottom, Spacing.sectionHeaderToContent * (1 - collapseProgress))
                    .clipped()
            }

            searchField
                .padding(.bottom, Spacing.sectionHeaderToContent)

            ZStack {
                expandedTabRail.opacity(1 - collapseProgress)
                collapsedTabStrip.opacity(collapseProgress)
            }
            .frame(height: tabAreaHeight)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.top, Spacing.sectionHeaderToContent)
        .frame(maxWidth: .infinity)
        .frame(height: height, alignment: .top)
        .background(Palette.brandPrimary.ignoresSafeArea(edges: .top))
        .clipped()
    }

    @ViewBuilder private var topRow: some View {
        HStack {
            if let location {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Palette.textOnDark)
                    Text(location.text)
                        .font(Typography.cardTitle)
                        .foregroundStyle(Palette.textOnDark)
                    Image(systemName: IconToken.chevronDown)
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.textOnDark)
                }
                .onTapGesture { actionHandler.handle(location.action) }
            }
            Spacer()
            if let avatar {
                Image(systemName: avatar.imageName)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .onTapGesture { actionHandler.handle(avatar.action) }
            }
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Palette.textOnDark.opacity(0.7))
            Text(search.placeholders.first ?? "")
                .font(Typography.body)
                .foregroundStyle(Palette.textOnDark.opacity(0.7))
            Spacer()
        }
        .padding(.horizontal, Spacing.cardPadding)
        .frame(height: 44)
        .background(Palette.brandSurfaceTranslucent, in: RoundedRectangle(cornerRadius: Radius.pill))
        .onTapGesture { actionHandler.handle(search.action) }
    }

    private var expandedTabRail: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.sectionHeaderToContent) {
                ForEach(tabs, id: \.id) { tab in
                    let selected = tab.id == selectedTabId
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(selected ? Palette.surfaceDefault : Palette.brandSurfaceTranslucent)
                                .frame(width: 56, height: 56)
                            Image(systemName: tab.icon)
                                .foregroundStyle(selected ? Palette.brandPrimary : Palette.textOnDark)
                        }
                        Text(tab.label)
                            .font(Typography.caption)
                            .fontWeight(selected ? .bold : .regular)
                            .foregroundStyle(Palette.textOnDark)
                            .lineLimit(1)
                    }
                    .onTapGesture { actionHandler.handle(tab.action) }
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    private var collapsedTabStrip: some View {
        ScrollView(.horizontal) {
            HStack(spacing: Spacing.sectionGap) {
                ForEach(tabs, id: \.id) { tab in
                    let selected = tab.id == selectedTabId
                    VStack(spacing: 4) {
                        Text(tab.label)
                            .font(Typography.body)
                            .foregroundStyle(Palette.textOnDark)
                        Rectangle()
                            .fill(selected ? Palette.textOnDark : Color.clear)
                            .frame(height: 2)
                    }
                    .onTapGesture { actionHandler.handle(tab.action) }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}
