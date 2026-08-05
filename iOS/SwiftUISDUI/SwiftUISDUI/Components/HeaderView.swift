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
//  (expanded), underline (collapsed). Non-`all` tab taps are inert in
//  Stage 2 (design_spec.md §5) — no PageStore to load another page yet.
//
//  location/avatar have no icon prop in COMPONENTS.md §9 — their pin/avatar
//  chrome is fixed client decoration, not server-token-driven, so it's
//  hardcoded here rather than routed through IconToken.
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
}

struct HeaderView: View {
    let location: HeaderLocationData?
    let avatar: HeaderAvatarData?
    let search: HeaderSearchData
    let tabs: [HeaderTab]
    let selectedTabId: String
    let collapseProgress: CGFloat

    private let expandedHeight: CGFloat = 280
    private let collapsedHeight: CGFloat = 104

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

    var body: some View {
        VStack(spacing: Spacing.sectionHeaderToContent) {
            topRow
                .opacity(1 - collapseProgress)
                .frame(height: 40 * (1 - collapseProgress))
                .clipped()

            searchField

            ZStack {
                expandedTabRail.opacity(1 - collapseProgress)
                collapsedTabStrip.opacity(collapseProgress)
            }
            .frame(height: 44)
        }
        .padding(.horizontal, Spacing.pageMargin)
        .padding(.top, 50)
        .padding(.bottom, Spacing.sectionHeaderToContent)
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
                .onTapGesture {}
            }
            Spacer()
            if let avatar {
                CachedImage(imageRef: avatar.image)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .onTapGesture {}
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
        .onTapGesture {}
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
                            .font(.system(size: 12, weight: selected ? .bold : .regular))
                            .foregroundStyle(Palette.textOnDark)
                            .lineLimit(1)
                    }
                    .onTapGesture {}
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
                            .font(.system(size: 15, weight: selected ? .bold : .regular))
                            .foregroundStyle(Palette.textOnDark)
                        Rectangle()
                            .fill(selected ? Palette.textOnDark : Color.clear)
                            .frame(height: 2)
                    }
                    .onTapGesture {}
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}
