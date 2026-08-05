//
//  StaticHomeData+UsedCarsAndVehicle.swift
//  SwiftUISDUI
//
//  See StaticHomeData.swift for the split rationale.
//

extension StaticHomeData {

    // MARK: - Used cars you'll love rail (filter: wishlisted / hot deals)

    static let usedCarsHeader = SectionHeader(
        title: "Used cars you'll love",
        trailing: ButtonSpec(text: "View all", action: Action(type: "navigate", target: "listing"), variant: .ghost)
    )

    static let usedCarsWishlisted: [CarCardItemData] = [
        CarCardItemData(
            id: "used_cars_rail_wishlisted__2023_mahindra_xuv300",
            image: ImageRef(url: "https://placehold.co/600x400/F1F3F9/333333?text=XUV300", aspect: 1.5),
            title: "2023 Mahindra XUV300", price: "\u{20B9}6.60 lakh",
            action: Action(type: "navigate", target: "car_detail", params: ["carId": "car_10021"]),
            overlayBadge: Badge(text: "Owned stock", variant: .accent),
            favorite: CarCardFavorite(selected: true, action: Action(type: "toggle", target: "car_10021")),
            subtitle: "W6 1.2 PETROL",
            specs: ["25,335 km", "Petrol", "Manual", "MH28"],
            priceSuffix: "EMI \u{20B9}11,651/m*",
            priceNote: CarCardPriceNote(
                text: "+other charges",
                action: Action(type: "openSheet", target: "price_breakup", params: ["carId": "car_10021"])
            ),
            trustBadges: [
                Badge(text: "Zero Worry Max", icon: IconToken.shield, variant: .accent),
                Badge(text: "Lifetime warranty", icon: IconToken.check, variant: .neutral)
            ]
        ),
        CarCardItemData(
            id: "used_cars_rail_wishlisted__2012_volkswagen_vento",
            image: ImageRef(url: "https://placehold.co/600x400/F1F3F9/333333?text=Vento", aspect: 1.5),
            title: "2012 Volkswagen Vento", price: "\u{20B9}1.72 lakh",
            action: Action(type: "navigate", target: "car_detail", params: ["carId": "car_10022"]),
            overlayBadge: Badge(text: "Verified Direct", variant: .warning),
            favorite: CarCardFavorite(selected: true, action: Action(type: "toggle", target: "car_10022")),
            subtitle: "HIGHLINE DIESEL 1.6",
            specs: ["78,002 km", "Diesel", "Manual", "KA01"],
            priceSuffix: nil,
            priceNote: CarCardPriceNote(text: "Price negotiable"),
            trustBadges: [
                Badge(text: "Zero Worry", icon: IconToken.check, variant: .accent)
            ]
        ),
        CarCardItemData(
            id: "used_cars_rail_wishlisted__2015_maruti_baleno",
            image: ImageRef(url: "https://placehold.co/600x400/F1F3F9/333333?text=Baleno", aspect: 1.5),
            title: "2015 Maruti Baleno", price: "\u{20B9}3.87 lakh",
            action: Action(type: "navigate", target: "car_detail", params: ["carId": "car_10023"]),
            overlayBadge: Badge(text: "Owned stock", variant: .accent),
            favorite: CarCardFavorite(selected: true, action: Action(type: "toggle", target: "car_10023")),
            subtitle: "DELTA CVT PETROL 1.2",
            specs: ["92,838 km", "Petrol", "Auto", "KA05"],
            priceSuffix: "EMI \u{20B9}10,191/m*",
            priceNote: CarCardPriceNote(
                text: "+other charges",
                action: Action(type: "openSheet", target: "price_breakup", params: ["carId": "car_10023"])
            ),
            trustBadges: [
                Badge(text: "Zero Worry Max", icon: IconToken.shield, variant: .accent),
                Badge(text: "Lifetime warranty", icon: IconToken.check, variant: .neutral)
            ]
        )
    ]

    static let usedCarsHotDeals: [CarCardItemData] = [
        CarCardItemData(
            id: "used_cars_rail_hot_deals__2019_maruti_swift",
            image: ImageRef(url: "https://placehold.co/600x400/F1F3F9/333333?text=Swift", aspect: 1.5),
            title: "2019 Maruti Swift", price: "\u{20B9}4.95 lakh",
            action: Action(type: "navigate", target: "car_detail", params: ["carId": "car_10031"]),
            overlayBadge: Badge(text: "Owned stock", variant: .accent),
            favorite: CarCardFavorite(selected: false, action: Action(type: "toggle", target: "car_10031")),
            subtitle: "VXI 1.2 PETROL",
            specs: ["41,204 km", "Petrol", "Manual", "KA03"],
            priceSuffix: "EMI \u{20B9}8,740/m*",
            priceNote: CarCardPriceNote(
                text: "+other charges",
                action: Action(type: "openSheet", target: "price_breakup", params: ["carId": "car_10031"])
            ),
            trustBadges: [
                Badge(text: "Zero Worry Max", icon: IconToken.shield, variant: .accent),
                Badge(text: "Lifetime warranty", icon: IconToken.check, variant: .neutral)
            ]
        ),
        CarCardItemData(
            id: "used_cars_rail_hot_deals__2021_hyundai_i20",
            image: ImageRef(url: "https://placehold.co/600x400/F1F3F9/333333?text=i20", aspect: 1.5),
            title: "2021 Hyundai i20", price: "\u{20B9}7.15 lakh",
            action: Action(type: "navigate", target: "car_detail", params: ["carId": "car_10032"]),
            overlayBadge: Badge(text: "Verified Direct", variant: .warning),
            favorite: CarCardFavorite(selected: false, action: Action(type: "toggle", target: "car_10032")),
            subtitle: "SPORTZ 1.2 PETROL",
            specs: ["29,410 km", "Petrol", "Manual", "KA51"],
            priceSuffix: "EMI \u{20B9}12,480/m*",
            priceNote: CarCardPriceNote(
                text: "+other charges",
                action: Action(type: "openSheet", target: "price_breakup", params: ["carId": "car_10032"])
            ),
            trustBadges: [
                Badge(text: "Zero Worry", icon: IconToken.check, variant: .accent)
            ]
        ),
        CarCardItemData(
            id: "used_cars_rail_hot_deals__2020_tata_nexon",
            image: ImageRef(url: "https://placehold.co/600x400/F1F3F9/333333?text=Nexon", aspect: 1.5),
            title: "2020 Tata Nexon", price: "\u{20B9}8.40 lakh",
            action: Action(type: "navigate", target: "car_detail", params: ["carId": "car_10033"]),
            overlayBadge: Badge(text: "Owned stock", variant: .accent),
            favorite: CarCardFavorite(selected: false, action: Action(type: "toggle", target: "car_10033")),
            subtitle: "XZ PLUS DIESEL 1.5",
            specs: ["55,120 km", "Diesel", "Manual", "KA02"],
            priceSuffix: "EMI \u{20B9}14,905/m*",
            priceNote: CarCardPriceNote(
                text: "+other charges",
                action: Action(type: "openSheet", target: "price_breakup", params: ["carId": "car_10033"])
            ),
            trustBadges: [
                Badge(text: "Zero Worry Max", icon: IconToken.shield, variant: .accent),
                Badge(text: "Lifetime warranty", icon: IconToken.check, variant: .neutral)
            ]
        )
    ]

    // MARK: - Manage your vehicle grid

    static let manageVehicleHeader = SectionHeader(
        title: "Manage your vehicle",
        trailing: ButtonSpec(text: "+ Add vehicle", action: Action(type: "openSheet", target: "add_vehicle"), variant: .ghost)
    )

    static let manageVehicleStyle = Style(background: Palette.surfaceBrand)

    static let manageVehicleItems: [TileItemData] = [
        TileItemData(
            id: "manage_vehicle_grid__pay_challan", title: "Pay challan",
            image: ImageRef(url: "https://placehold.co/160x120/FFFFFF/333333?text=Challan", aspect: 1.33),
            style: Style(background: Palette.surfaceDefault, foreground: Palette.textPrimary, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "pay_challan")
        ),
        TileItemData(
            id: "manage_vehicle_grid__recharge_fastag", title: "Recharge FASTag",
            image: ImageRef(url: "https://placehold.co/160x120/FFFFFF/333333?text=FASTag", aspect: 1.33),
            style: Style(background: Palette.surfaceDefault, foreground: Palette.textPrimary, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "fastag")
        ),
        TileItemData(
            id: "manage_vehicle_grid__get_insurance", title: "Get insurance",
            image: ImageRef(url: "https://placehold.co/160x120/FFFFFF/333333?text=Insurance", aspect: 1.33),
            style: Style(background: Palette.surfaceDefault, foreground: Palette.textPrimary, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "get_insurance")
        ),
        TileItemData(
            id: "manage_vehicle_grid__cash_against_car", title: "Cash against car",
            image: ImageRef(url: "https://placehold.co/160x120/FFFFFF/333333?text=Cash", aspect: 1.33),
            style: Style(background: Palette.surfaceDefault, foreground: Palette.textPrimary, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "cash_against_car")
        ),
        TileItemData(
            id: "manage_vehicle_grid__road_side_assistance", title: "Road side assistance",
            image: ImageRef(url: "https://placehold.co/160x120/FFFFFF/333333?text=RSA", aspect: 1.33),
            style: Style(background: Palette.surfaceDefault, foreground: Palette.textPrimary, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "rsa")
        ),
        TileItemData(
            id: "manage_vehicle_grid__get_warranty", title: "Get warranty",
            image: ImageRef(url: "https://placehold.co/160x120/FFFFFF/333333?text=Warranty", aspect: 1.33),
            style: Style(background: Palette.surfaceDefault, foreground: Palette.textPrimary, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "get_warranty")
        )
    ]
}
