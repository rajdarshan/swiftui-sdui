//
//  StaticItemData.swift
//  SwiftUISDUI
//
//  Identifiable wrappers so hardcoded static items can feed RailView/
//  GridView/CarouselView's generic `[Item: Identifiable]` requirement. Stage
//  3's decoder may or may not reuse this exact shape — it's a Stage 2
//  static-data concern, not part of the shared leaf-view contract itself.
//

struct TileItemData: Identifiable {
    let id: String
    let title: String
    let image: ImageRef?
    let style: Style?
    let action: Action
}

struct IconTileItemData: Identifiable {
    let id: String
    let label: String
    let image: ImageRef
    let imageShape: IconTileImageShape
    let action: Action
}

struct CarCardItemData: Identifiable {
    let id: String
    let image: ImageRef
    let title: String
    let price: String
    let action: Action
    let overlayBadge: Badge?
    let favorite: CarCardFavorite?
    let subtitle: String?
    let specs: [String]
    let priceSuffix: String?
    let priceNote: CarCardPriceNote?
    let trustBadges: [Badge]
}

struct PlaceCardItemData: Identifiable {
    let id: String
    let images: [ImageRef]
    let title: String
    let overlayBadge: Badge?
    let subtitle: String?
    let linkRow: PlaceCardLinkRow?
    let status: PlaceCardStatus?
    let buttons: [ButtonSpec]
}

struct ModelCardItemData: Identifiable {
    let id: String
    let title: String
    let image: ImageRef
    let subtitle: String?
    let watermark: String?
    let style: Style?
    let action: Action
}

struct PromoCardItemData: Identifiable {
    let id: String
    let title: String
    let image: ImageRef?
    let eyebrow: String?
    let subtitle: String?
    let logos: [ImageRef]
    let button: ButtonSpec?
    let style: Style?
}

/// `single`-section items (find_match_card) aren't rendered via a ForEach,
/// so they don't need Identifiable — just the leaf view's own params grouped
/// for a single `static let`.
struct FeatureCardData {
    let title: String
    let bodyText: String?
    let image: ImageRef?
    let imagePosition: FeatureCardImagePosition
    let badge: Badge?
    let footer: FeatureCardFooter?
}
