//
//  StaticHomeView.swift
//  SwiftUISDUI
//
//  design_spec.md §5: full 14-section parity with the SDUI screen, same
//  leaf views fed hardcoded values, header with all 7 tabs (non-`all` taps
//  inert), no decoder/registry/PageStore.
//
//  Page scroll: ScrollView + LazyVStack(spacing: 24) per design_spec.md
//  §4.1. availableWidth measured once here via .onGeometryChange and
//  injected through @Environment — never a nested GeometryReader.
//  collapseProgress for HeaderView is likewise computed here, once, from
//  .onScrollGeometryChange, and passed down as a plain value.
//
//  used_cars_rail's filter chips get real tap-to-switch @State — local UI
//  state, not an Action dispatch, per the Stage 2 plan's scope decisions.
//

import SwiftUI

struct StaticHomeView: View {
    @State private var collapseProgress: CGFloat = 0
    @State private var availableWidth: CGFloat = 0
    @State private var usedCarsSelectedChipId = "wishlisted"

    private let collapseScrollRange: CGFloat = 280 - 104

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(spacing: Spacing.sectionGap) {
                    Color.clear.frame(height: 280)

                    SectionContainer(header: StaticHomeData.buyCarHeader) {
                        RailView(items: StaticHomeData.buyCarItems, itemWidth: .sm) { item in
                            TileView(title: item.title, image: item.image, style: item.style, action: item.action)
                        }
                    }

                    SectionContainer(header: StaticHomeData.sellCarHeader) {
                        RailView(items: StaticHomeData.sellCarItems, itemWidth: .sm) { item in
                            TileView(title: item.title, image: item.image, style: item.style, action: item.action)
                        }
                    }

                    SectionContainer(header: StaticHomeData.loansHeader) {
                        RailView(items: StaticHomeData.loansItems, itemWidth: .sm) { item in
                            IconTileView(label: item.label, image: item.image, imageShape: item.imageShape, action: item.action)
                        }
                    }

                    SectionContainer(header: StaticHomeData.carCheckHeader) {
                        GridView(items: StaticHomeData.carCheckItems, columns: 3) { item in
                            TileView(title: item.title, image: item.image, style: item.style, action: item.action)
                        }
                    }

                    SectionContainer(header: StaticHomeData.usedCarsHeader) {
                        usedCarsSection
                    }

                    SectionContainer(header: StaticHomeData.manageVehicleHeader, style: StaticHomeData.manageVehicleStyle) {
                        GridView(items: StaticHomeData.manageVehicleItems, columns: 3) { item in
                            TileView(title: item.title, image: item.image, style: item.style, action: item.action)
                        }
                    }

                    SectionContainer {
                        PromoCardView(
                            title: StaticHomeData.orbitPromo.title, image: StaticHomeData.orbitPromo.image,
                            eyebrow: StaticHomeData.orbitPromo.eyebrow, subtitle: StaticHomeData.orbitPromo.subtitle,
                            logos: StaticHomeData.orbitPromo.logos, button: StaticHomeData.orbitPromo.button,
                            style: StaticHomeData.orbitPromo.style
                        )
                        .padding(.horizontal, Spacing.pageMargin)
                    }

                    SectionContainer(header: StaticHomeData.showroomsHeader) {
                        RailView(items: StaticHomeData.showroomsItems, itemWidth: .xl) { item in
                            PlaceCardView(
                                images: item.images, title: item.title, overlayBadge: item.overlayBadge,
                                subtitle: item.subtitle, linkRow: item.linkRow, status: item.status, buttons: item.buttons
                            )
                        }
                    }

                    SectionContainer(header: StaticHomeData.trendingHeader) {
                        RailView(items: StaticHomeData.trendingItems, itemWidth: .md) { item in
                            ModelCardView(
                                title: item.title, image: item.image, subtitle: item.subtitle,
                                watermark: item.watermark, style: item.style, action: item.action
                            )
                        }
                    }

                    SectionContainer {
                        FeatureCardView(
                            title: StaticHomeData.findMatch.title, bodyText: StaticHomeData.findMatch.bodyText,
                            image: StaticHomeData.findMatch.image, imagePosition: StaticHomeData.findMatch.imagePosition,
                            badge: StaticHomeData.findMatch.badge, footer: StaticHomeData.findMatch.footer
                        )
                        .padding(.horizontal, Spacing.pageMargin)
                    }

                    SectionContainer {
                        CarouselView(items: StaticHomeData.valuePropItems, loop: true, peek: true) { item in
                            PromoCardView(
                                title: item.title, image: item.image, eyebrow: item.eyebrow,
                                subtitle: item.subtitle, logos: item.logos, button: item.button, style: item.style
                            )
                        }
                    }

                    SectionContainer {
                        PromoCardView(
                            title: StaticHomeData.crashfreePromo.title, image: StaticHomeData.crashfreePromo.image,
                            eyebrow: StaticHomeData.crashfreePromo.eyebrow, subtitle: StaticHomeData.crashfreePromo.subtitle,
                            logos: StaticHomeData.crashfreePromo.logos, button: StaticHomeData.crashfreePromo.button,
                            style: StaticHomeData.crashfreePromo.style
                        )
                        .padding(.horizontal, Spacing.pageMargin)
                    }

                    SectionContainer(style: StaticHomeData.brandFooterStyle) {
                        TextBlockView(
                            title: StaticHomeData.brandFooterTitle, subtitle: StaticHomeData.brandFooterSubtitle,
                            style: StaticHomeData.brandFooterTextStyle
                        )
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.y }, action: updateCollapseProgress)
            .environment(\.availableWidth, availableWidth)

            HeaderView(
                location: StaticHomeData.headerLocation,
                avatar: StaticHomeData.headerAvatar,
                search: StaticHomeData.headerSearch,
                tabs: StaticHomeData.headerTabs,
                selectedTabId: StaticHomeData.selectedTabId,
                collapseProgress: collapseProgress
            )
        }
        .measuringAvailableWidth(into: $availableWidth)
        .ignoresSafeArea(edges: .top)
    }

    private func updateCollapseProgress(oldValue: CGFloat, newValue: CGFloat) {
        collapseProgress = min(max(newValue / collapseScrollRange, 0), 1)
    }

    private var usedCarsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sectionHeaderToContent) {
            usedCarsChips
            RailView(items: usedCarsSelectedItems, itemWidth: .lg) { item in
                CarCardView(
                    image: item.image, title: item.title, price: item.price, action: item.action,
                    overlayBadge: item.overlayBadge, favorite: item.favorite, subtitle: item.subtitle,
                    specs: item.specs, priceSuffix: item.priceSuffix, priceNote: item.priceNote,
                    trustBadges: item.trustBadges
                )
            }
        }
    }

    private var usedCarsSelectedItems: [CarCardItemData] {
        usedCarsSelectedChipId == "wishlisted" ? StaticHomeData.usedCarsWishlisted : StaticHomeData.usedCarsHotDeals
    }

    private var usedCarsChips: some View {
        HStack(spacing: Spacing.sectionHeaderToContent) {
            chipButton(label: "Wishlisted", id: "wishlisted")
            chipButton(label: "Hot deals", id: "hot_deals")
        }
        .padding(.horizontal, Spacing.pageMargin)
    }

    private func chipButton(label: String, id: String) -> some View {
        let selected = usedCarsSelectedChipId == id
        return Text(label)
            .font(Typography.link)
            .foregroundStyle(selected ? Palette.brandPrimary : Palette.textSecondary)
            .padding(.horizontal, Spacing.cardPadding)
            .frame(height: 36)
            .background(Palette.surfaceDefault, in: Capsule())
            .overlay(Capsule().strokeBorder(selected ? Palette.brandPrimary : Palette.textSecondary.opacity(0.3)))
            .onTapGesture { usedCarsSelectedChipId = id }
    }
}
