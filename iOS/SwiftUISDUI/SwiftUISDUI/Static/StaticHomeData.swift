//
//  StaticHomeData.swift
//  SwiftUISDUI
//
//  design_spec.md §5: mirrors sdui-config/payloads/home_all.json exactly —
//  same titles, prices, counts, order. No decoder, no registry, no
//  PageStore on this path.
//
//  Split across StaticHomeData.swift / +UsedCarsAndVehicle.swift / +Promos.swift
//  by section group — one `enum StaticHomeData` body would exceed
//  .swiftlint.yml's type_body_length/file_length limits otherwise.
//

import SwiftUI

enum StaticHomeData {

    // MARK: - Header

    static let headerTabs: [HeaderTab] = [
        HeaderTab(id: "all", label: "All", icon: IconToken.grid, action: Action(type: "navigate", target: "home_all")),
        HeaderTab(id: "buy_used_car", label: "Buy used car", icon: IconToken.car,
                  action: Action(type: "navigate", target: "home_buy_used_car")),
        HeaderTab(id: "sell_car", label: "Sell car", icon: IconToken.key,
                  action: Action(type: "navigate", target: "home_sell_car")),
        HeaderTab(id: "loans", label: "Loans", icon: IconToken.money,
                  action: Action(type: "navigate", target: "home_loans")),
        HeaderTab(id: "challan", label: "Challan", icon: IconToken.receipt,
                  action: Action(type: "navigate", target: "home_challan")),
        HeaderTab(id: "car_check", label: "Car check", icon: IconToken.wrench,
                  action: Action(type: "navigate", target: "home_car_check")),
        HeaderTab(id: "insurance", label: "Insurance", icon: IconToken.shield,
                  action: Action(type: "navigate", target: "home_insurance"))
    ]

    static let selectedTabId = "all"

    static let headerLocation = HeaderLocationData(
        text: "Bangalore",
        action: Action(type: "openSheet", target: "city_picker")
    )

    static let headerAvatar = HeaderAvatarData(
        image: ImageRef(url: "https://placehold.co/96x96/FFFFFF/382BC3?text=P"),
        action: Action(type: "navigate", target: "profile")
    )

    static let headerSearch = HeaderSearchData(
        placeholders: [
            "Search Creta", "Search Tata cars", "Search Ertiga", "Search Swift",
            "Search Maruti cars", "Search Thar", "Search Baleno"
        ],
        action: Action(type: "search", target: "search")
    )

    // MARK: - Buy car rail

    static let buyCarHeader = SectionHeader(
        title: "Buy car",
        badge: Badge(text: "Up to \u{20B9}80,000 off", variant: .danger)
    )

    static let buyCarItems: [TileItemData] = [
        TileItemData(
            id: "buy_car_rail__all_used_cars", title: "All used cars",
            image: ImageRef(url: "https://placehold.co/240x160/1E3A8A/FFFFFF?text=Used+cars", aspect: 1.5),
            style: Style(background: Palette.tileBlue, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "listing", params: ["filter": "all"])
        ),
        TileItemData(
            id: "buy_car_rail__budget_used_cars", title: "Budget used cars",
            image: ImageRef(url: "https://placehold.co/240x160/1E3A8A/FFFFFF?text=Budget", aspect: 1.5),
            style: Style(background: Palette.tileBlue, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "listing", params: ["filter": "budget"])
        ),
        TileItemData(
            id: "buy_car_rail__premium_used_cars", title: "Premium used cars",
            image: ImageRef(url: "https://placehold.co/240x160/1E3A8A/FFFFFF?text=Premium", aspect: 1.5),
            style: Style(background: Palette.tileBlue, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "listing", params: ["filter": "premium"])
        ),
        TileItemData(
            id: "buy_car_rail__new_cars", title: "New cars",
            image: ImageRef(url: "https://placehold.co/240x160/1E3A8A/FFFFFF?text=New+cars", aspect: 1.5),
            style: Style(background: Palette.tileBlue, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "new_cars")
        ),
        TileItemData(
            id: "buy_car_rail__cars_under_5_lakh", title: "Cars under \u{20B9}5 lakh",
            image: ImageRef(url: "https://placehold.co/240x160/1E3A8A/FFFFFF?text=Under+5L", aspect: 1.5),
            style: Style(background: Palette.tileBlue, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "listing", params: ["maxPrice": "500000"])
        )
    ]

    // MARK: - Sell your car rail

    static let sellCarHeader = SectionHeader(title: "Sell your car")

    static let sellCarItems: [TileItemData] = [
        TileItemData(
            id: "sell_car_rail__sell_your_car", title: "Sell your car",
            image: ImageRef(url: "https://placehold.co/240x160/2F5D3A/FFFFFF?text=Sell", aspect: 1.5),
            style: Style(background: Palette.tileGreen, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "sell_flow")
        ),
        TileItemData(
            id: "sell_car_rail__check_car_valuation", title: "Check car valuation",
            image: ImageRef(url: "https://placehold.co/240x160/2F5D3A/FFFFFF?text=Valuation", aspect: 1.5),
            style: Style(background: Palette.tileGreen, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "valuation")
        ),
        TileItemData(
            id: "sell_car_rail__scrap_your_car", title: "Scrap your car",
            image: ImageRef(url: "https://placehold.co/240x160/2F5D3A/FFFFFF?text=Scrap", aspect: 1.5),
            style: Style(background: Palette.tileGreen, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "scrap")
        ),
        TileItemData(
            id: "sell_car_rail__exchange_car", title: "Exchange car",
            image: ImageRef(url: "https://placehold.co/240x160/2F5D3A/FFFFFF?text=Exchange", aspect: 1.5),
            style: Style(background: Palette.tileGreen, foreground: Palette.textOnDark, cornerRadius: Radius.lg),
            action: Action(type: "navigate", target: "exchange")
        )
    ]

    // MARK: - Get loans rail

    static let loansHeader = SectionHeader(title: "Get loans")

    static let loansItems: [IconTileItemData] = [
        IconTileItemData(
            id: "loans_rail__used_car_loan", label: "Used car loan",
            image: ImageRef(url: "https://placehold.co/280x280/DCE6FB/1E3A8A?text=Car+loan", aspect: 1.0),
            imageShape: .arch,
            action: Action(type: "navigate", target: "loan", params: ["product": "used_car"])
        ),
        IconTileItemData(
            id: "loans_rail__loan_against_car", label: "Loan against car",
            image: ImageRef(url: "https://placehold.co/280x280/DCE6FB/1E3A8A?text=Against+car", aspect: 1.0),
            imageShape: .arch,
            action: Action(type: "navigate", target: "loan", params: ["product": "against_car"])
        ),
        IconTileItemData(
            id: "loans_rail__personal_loan", label: "Personal loan",
            image: ImageRef(url: "https://placehold.co/280x280/DCE6FB/1E3A8A?text=Personal", aspect: 1.0),
            imageShape: .arch,
            action: Action(type: "navigate", target: "loan", params: ["product": "personal"])
        ),
        IconTileItemData(
            id: "loans_rail__credit_score", label: "Credit score",
            image: ImageRef(url: "https://placehold.co/280x280/DCE6FB/1E3A8A?text=Credit", aspect: 1.0),
            imageShape: .arch,
            action: Action(type: "navigate", target: "credit_score")
        )
    ]

    // MARK: - Car check services grid

    static let carCheckHeader = SectionHeader(title: "Car check services")

    static let carCheckItems: [TileItemData] = [
        TileItemData(
            id: "car_check_grid__new_car_pdi", title: "New car PDI",
            image: ImageRef(url: "https://placehold.co/160x120/FBF3E4/8A6D3B?text=PDI", aspect: 1.33),
            style: Style(background: Palette.tileCream, foreground: Palette.textPrimary,
                         border: Palette.tileCreamBorder, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "pdi")
        ),
        TileItemData(
            id: "car_check_grid__used_car_check", title: "Used car check",
            image: ImageRef(url: "https://placehold.co/160x120/FBF3E4/8A6D3B?text=Check", aspect: 1.33),
            style: Style(background: Palette.tileCream, foreground: Palette.textPrimary,
                         border: Palette.tileCreamBorder, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "used_car_check")
        ),
        TileItemData(
            id: "car_check_grid__vehicle_history", title: "Vehicle history",
            image: ImageRef(url: "https://placehold.co/160x120/FBF3E4/8A6D3B?text=History", aspect: 1.33),
            style: Style(background: Palette.tileCream, foreground: Palette.textPrimary,
                         border: Palette.tileCreamBorder, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "vehicle_history")
        ),
        TileItemData(
            id: "car_check_grid__check_challan", title: "Check challan",
            image: ImageRef(url: "https://placehold.co/160x120/FBF3E4/8A6D3B?text=Challan", aspect: 1.33),
            style: Style(background: Palette.tileCream, foreground: Palette.textPrimary,
                         border: Palette.tileCreamBorder, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "check_challan")
        ),
        TileItemData(
            id: "car_check_grid__check_car_insurance", title: "Check car insurance",
            image: ImageRef(url: "https://placehold.co/160x120/FBF3E4/8A6D3B?text=Insurance", aspect: 1.33),
            style: Style(background: Palette.tileCream, foreground: Palette.textPrimary,
                         border: Palette.tileCreamBorder, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "check_insurance")
        ),
        TileItemData(
            id: "car_check_grid__odometer_tampering", title: "Odometer tampering",
            image: ImageRef(url: "https://placehold.co/160x120/FBF3E4/8A6D3B?text=Odometer", aspect: 1.33),
            style: Style(background: Palette.tileCream, foreground: Palette.textPrimary,
                         border: Palette.tileCreamBorder, cornerRadius: Radius.md),
            action: Action(type: "navigate", target: "odometer_check")
        )
    ]
}
