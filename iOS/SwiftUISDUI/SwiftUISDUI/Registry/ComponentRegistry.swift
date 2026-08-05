//
//  ComponentRegistry.swift
//  SwiftUISDUI
//
//  design_spec.md §3.2 rule 3: "Registry is a dictionary keyed by the type
//  string, holding a decode closure and a view closure per type. Not a
//  Swift enum." Stage 3 built the decode half; Stage 4 adds the parallel
//  `itemViews` field for rendering — adding a future component stays "one
//  new file plus one registration line" per dictionary.
//
//  `itemDecoders` stays `nonisolated` (constructed/read from Decodable's
//  nonisolated `init(from:)` contexts, design_spec.md §3.3). `itemViews`
//  builds SwiftUI views, which are @MainActor by the module's default
//  isolation, so it's marked `@MainActor` explicitly rather than forcing the
//  whole struct nonisolated — `ComponentRegistry.shared` is read from both a
//  nonisolated decode path and a @MainActor render path.
//
//  Only item types go through this dictionary. Section containers (rail,
//  grid, carousel, list, single, header) are a fixed set of 5 (+ header)
//  with no analogous extension workflow (SectionNode.swift's own comment),
//  so section-level view composition is a plain `switch` in SDUIPageView,
//  mirroring SectionDecoding.swift's decode-side `switch` rather than a
//  second registry dictionary.
//

import SwiftUI

/// Per-render context an item view closure may need beyond the node itself.
/// `toggledIds` is Stage 4's local wishlist-heart state (PageStore owns the
/// set; `carCard`'s effective `favorite.selected` is `favorite.selected !=
/// toggledIds.contains(id)`, computed here rather than stored on the node).
nonisolated struct ItemRenderContext {
    let toggledIds: Set<String>

    init(toggledIds: Set<String> = []) {
        self.toggledIds = toggledIds
    }
}

nonisolated struct ComponentRegistry {
    let itemDecoders: [String: (Decoder) throws -> any ItemNode]
    @MainActor let itemViews: [String: @MainActor (any ItemNode, ItemRenderContext) -> AnyView]

    static let shared = ComponentRegistry(
        itemDecoders: [
            "tile": { try TileNode(from: $0) },
            "modelCard": { try ModelCardNode(from: $0) },
            "iconTile": { try IconTileNode(from: $0) },
            "carCard": { try CarCardNode(from: $0) },
            "placeCard": { try PlaceCardNode(from: $0) },
            "promoCard": { try PromoCardNode(from: $0) },
            "featureCard": { try FeatureCardNode(from: $0) },
            "textBlock": { try TextBlockNode(from: $0) }
        ],
        itemViews: [
            "tile": { node, _ in
                guard let tile = node as? TileNode else { return AnyView(EmptyView()) }
                return AnyView(TileView(title: tile.title, image: tile.image, style: tile.style, action: tile.action, imageName: nil))
            },
            "modelCard": { node, _ in
                guard let card = node as? ModelCardNode else { return AnyView(EmptyView()) }
                return AnyView(ModelCardView(
                    title: card.title, image: card.image, subtitle: card.subtitle,
                    watermark: card.watermark, style: card.style, action: card.action
                ))
            },
            "iconTile": { node, _ in
                guard let tile = node as? IconTileNode else { return AnyView(EmptyView()) }
                // imageName is unused when useImageAsset is false (the SDUI
                // screen's default, Static/StaticHomeData.swift) — SDUI
                // payloads only ever carry a remote ImageRef, never a local
                // asset name.
                return AnyView(IconTileView(
                    label: tile.label, image: tile.image, imageShape: tile.imageShape, imageName: "", action: tile.action
                ))
            },
            "carCard": { node, context in
                guard let card = node as? CarCardNode else { return AnyView(EmptyView()) }
                let favorite = card.favorite.map { fav in
                    CarCardFavorite(selected: fav.selected != context.toggledIds.contains(card.id), action: fav.action)
                }
                let priceNote = card.priceNote.map { CarCardPriceNote(text: $0.text, action: $0.action) }
                return AnyView(CarCardView(
                    image: card.image, title: card.title, price: card.price, action: card.action,
                    overlayBadge: card.overlayBadge, favorite: favorite, subtitle: card.subtitle,
                    specs: card.specs, priceSuffix: card.priceSuffix, priceNote: priceNote, trustBadges: card.trustBadges
                ))
            },
            "placeCard": { node, _ in
                guard let card = node as? PlaceCardNode else { return AnyView(EmptyView()) }
                return AnyView(PlaceCardView(
                    images: card.images, title: card.title, overlayBadge: card.overlayBadge,
                    subtitle: card.subtitle, linkRow: card.linkRow, status: card.status, buttons: card.buttons
                ))
            },
            "promoCard": { node, _ in
                guard let card = node as? PromoCardNode else { return AnyView(EmptyView()) }
                return AnyView(PromoCardView(
                    title: card.title, image: card.image, eyebrow: card.eyebrow, subtitle: card.subtitle,
                    logos: card.logos, button: card.button, style: card.style
                ))
            },
            "featureCard": { node, _ in
                guard let card = node as? FeatureCardNode else { return AnyView(EmptyView()) }
                return AnyView(FeatureCardView(
                    title: card.title, bodyText: card.bodyText, image: card.image,
                    imagePosition: card.imagePosition, badge: card.badge, footer: card.footer
                ))
            },
            "textBlock": { node, _ in
                guard let block = node as? TextBlockNode else { return AnyView(EmptyView()) }
                return AnyView(TextBlockView(title: block.title, subtitle: block.subtitle, style: block.style))
            }
        ]
    )
}

nonisolated extension CodingUserInfoKey {
    static let componentRegistry: CodingUserInfoKey = {
        // CodingUserInfoKey.init(rawValue:) only fails for an empty string —
        // never the case for this literal.
        guard let key = CodingUserInfoKey(rawValue: "componentRegistry") else {
            fatalError("CodingUserInfoKey(rawValue:) failed for a non-empty literal")
        }
        return key
    }()
}
