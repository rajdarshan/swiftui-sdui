//
//  StaticHomeData+Promos.swift
//  SwiftUISDUI
//
//  See StaticHomeData.swift for the split rationale.
//

extension StaticHomeData {

    // MARK: - Orbit promo (single)

    static let orbitPromo = PromoCardItemData(
        id: "orbit_promo__add_your_car_to_orbit",
        title: "-",
        image: ImageRef(url: "https://placehold.co/720x400/1B2B22/FFFFFF?text=Orbit", aspect: 1.8),
        eyebrow: nil,
        subtitle: nil,
        logos: [ ],
        button: nil,
        style: Style(background: Palette.tileDark, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
        imageName: "banner_spot"
    )

    // MARK: - Showrooms rail

    static let showroomsHeader = SectionHeader(title: "7 showrooms in your city")

    static let showroomsItems: [PlaceCardItemData] = [
        PlaceCardItemData(
            id: "showrooms_rail__right_parking_mlcp",
            images: [
                ImageRef(url: "https://placehold.co/900x600/1E3A8A/FFFFFF?text=Showroom+1", aspect: 1.5),
                ImageRef(url: "https://placehold.co/900x600/1E3A8A/FFFFFF?text=Showroom+1b", aspect: 1.5)
            ],
            title: "Right Parking MLCP",
            overlayBadge: Badge(text: "90+ cars", variant: .neutral),
            subtitle: "Gandhi Nagar, Bengaluru",
            linkRow: PlaceCardLinkRow(
                text: "2.7 km from MG Road | Get directions", trailingIcon: IconToken.directions,
                action: Action(type: "openMaps", target: "showroom_101", params: ["lat": "12.9767", "lng": "77.5713"])
            ),
            status: PlaceCardStatus(text: "Open", detail: "Closes at 08:00 PM", variant: .success),
            buttons: [
                ButtonSpec(text: "Call us now", action: Action(type: "call", target: "+918001234567"),
                           variant: .outline, leadingIcon: IconToken.phone),
                ButtonSpec(text: "View showroom",
                           action: Action(type: "navigate", target: "showroom_detail", params: ["showroomId": "showroom_101"]),
                           variant: .filled)
            ],
            imageNames: ["showroom_1", "showroom_2"]
        ),
        PlaceCardItemData(
            id: "showrooms_rail__nexus_koramangala",
            images: [ImageRef(url: "https://placehold.co/900x600/1E3A8A/FFFFFF?text=Showroom+2", aspect: 1.5)],
            title: "Nexus Koramangala",
            overlayBadge: Badge(text: "80+ cars", variant: .neutral),
            subtitle: "Koramangala, Bengaluru",
            linkRow: PlaceCardLinkRow(
                text: "4.6 km from MG Road | Get directions", trailingIcon: IconToken.directions,
                action: Action(type: "openMaps", target: "showroom_102", params: ["lat": "12.9352", "lng": "77.6245"])
            ),
            status: PlaceCardStatus(text: "Open", detail: "Closes at 09:00 PM", variant: .success),
            buttons: [
                ButtonSpec(text: "Call us now", action: Action(type: "call", target: "+918001234568"),
                           variant: .outline, leadingIcon: IconToken.phone),
                ButtonSpec(text: "View showroom",
                           action: Action(type: "navigate", target: "showroom_detail", params: ["showroomId": "showroom_102"]),
                           variant: .filled)
            ],
            imageNames: ["showroom_3", "showroom_4"]
        ),
        PlaceCardItemData(
            id: "showrooms_rail__whitefield_hub",
            images: [ImageRef(url: "https://placehold.co/900x600/1E3A8A/FFFFFF?text=Showroom+3", aspect: 1.5)],
            title: "Whitefield Hub",
            overlayBadge: Badge(text: "120+ cars", variant: .neutral),
            subtitle: "Whitefield, Bengaluru",
            linkRow: PlaceCardLinkRow(
                text: "14.2 km from MG Road | Get directions", trailingIcon: IconToken.directions,
                action: Action(type: "openMaps", target: "showroom_103", params: ["lat": "12.9698", "lng": "77.7500"])
            ),
            status: PlaceCardStatus(text: "Closed", detail: "Opens at 10:00 AM", variant: .danger),
            buttons: [
                ButtonSpec(text: "Call us now", action: Action(type: "call", target: "+918001234569"),
                           variant: .outline, leadingIcon: IconToken.phone),
                ButtonSpec(text: "View showroom",
                           action: Action(type: "navigate", target: "showroom_detail", params: ["showroomId": "showroom_103"]),
                           variant: .filled)
            ],
            imageNames: ["showroom_5", "showroom_6"]
        )
    ]

    // MARK: - Trending new cars rail

    static let trendingHeader = SectionHeader(
        title: "Trending new cars",
        trailing: ButtonSpec(text: "View all", action: Action(type: "navigate", target: "new_cars"), variant: .ghost)
    )

    static let trendingItems: [ModelCardItemData] = [
        ModelCardItemData(
            id: "trending_new_cars_rail__seltos", title: "Seltos",
            image: ImageRef(url: "https://placehold.co/600x400/EDF0F7/333333?text=Seltos", aspect: 1.5),
            subtitle: "Kia", watermark: "1",
            style: Style(background: Palette.surfaceMuted, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "new_car_detail", params: ["modelId": "kia_seltos"]),
            imageName: "trending_1"
        ),
        ModelCardItemData(
            id: "trending_new_cars_rail__sonet", title: "Sonet",
            image: ImageRef(url: "https://placehold.co/600x400/EDF0F7/333333?text=Sonet", aspect: 1.5),
            subtitle: "Kia", watermark: "2",
            style: Style(background: Palette.surfaceMuted, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "new_car_detail", params: ["modelId": "kia_sonet"]),
            imageName: "trending_2"
        ),
        ModelCardItemData(
            id: "trending_new_cars_rail__syros", title: "Syros",
            image: ImageRef(url: "https://placehold.co/600x400/EDF0F7/333333?text=Syros", aspect: 1.5),
            subtitle: "Kia", watermark: "3",
            style: Style(background: Palette.surfaceMuted, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "new_car_detail", params: ["modelId": "kia_syros"]),
            imageName: "trending_3"
        ),
        ModelCardItemData(
            id: "trending_new_cars_rail__carens", title: "Carens",
            image: ImageRef(url: "https://placehold.co/600x400/EDF0F7/333333?text=Carens", aspect: 1.5),
            subtitle: "Kia", watermark: "4",
            style: Style(background: Palette.surfaceMuted, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "new_car_detail", params: ["modelId": "kia_carens"]),
            imageName: "trending_4"
        )
    ]

    // MARK: - Find your match (single)

    static let findMatch = FeatureCardData(
        title: "Let us find your match",
        bodyText: "Answer a few simple questions and get your perfect car match in 60 seconds.",
        image: ImageRef(url: "https://placehold.co/400x600/4338CA/FFFFFF?text=Match", aspect: 0.67),
        imagePosition: .leading,
        badge: Badge(text: "Recommended", variant: .accent),
        footer: FeatureCardFooter(
            text: "Find my perfect match", trailingIcon: IconToken.arrowRightCircle,
            action: Action(type: "navigate", target: "match_quiz")
        ),
        imageName: "banner_hero"
    )

    // MARK: - Value prop carousel

    static let valuePropItems: [PromoCardItemData] = [
        PromoCardItemData(
            id: "value_prop_carousel__india_s_first_a_warranty_tha",
            title: "-",
            image: ImageRef(url: "https://placehold.co/720x400/3B2FCF/FFFFFF?text=Lifetime+warranty", aspect: 1.8),
            eyebrow: nil, subtitle: nil, logos: [],
            button: nil,
            style: Style(background: Palette.brandPrimary, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            imageName: "Carousel_1"
        ),
        PromoCardItemData(
            id: "value_prop_carousel__30_day_return_guarantee_on_e",
            title: "-",
            image: ImageRef(url: "https://placehold.co/720x400/C2410C/FFFFFF?text=30+day+return", aspect: 1.8),
            eyebrow: nil, subtitle: nil, logos: [],
            button: nil,
            style: Style(background: Palette.tileOrange, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            imageName: "Carousel_2"
        ),
        PromoCardItemData(
            id: "value_prop_carousel__3_free_services_with_every_c",
            title: "-",
            image: ImageRef(url: "https://placehold.co/720x400/15803D/FFFFFF?text=Free+services", aspect: 1.8),
            eyebrow: nil, subtitle: nil, logos: [],
            button: nil,
            style: Style(background: Palette.tileGreen, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            imageName: "Carousel_3"
        )
    ]

    // MARK: - Crashfree promo (single)

    static let crashfreePromo = PromoCardItemData(
        id: "crashfree_promo__control_judgment_patience",
        title: ".",
        image: ImageRef(url: "https://placehold.co/600x500/5B4FE8/FFFFFF?text=Crashfree", aspect: 1.2),
        eyebrow: nil,
        subtitle: nil,
        logos: [],
        button: nil,
        style: Style(background: Palette.brandPrimaryLight, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
        imageName: "Banner_Dhoni"
    )

    // MARK: - Brand footer (single)

    static let brandFooterStyle = Style(background: Palette.brandPrimaryLight)
    static let brandFooterTitle = "better drives, better lives"
    static let brandFooterSubtitle = "Made with \u{2764}\u{FE0F} in Gurugram"
    static let brandFooterTextStyle = Style(foreground: Palette.textOnDark)
}
