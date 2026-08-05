//
//  Palette.swift
//  SwiftUISDUI
//
//  Colour tokens. design_spec.md §2.1, token names fixed by COMPONENTS.md §5.
//

import SwiftUI

private func hexColor(_ hex: String) -> Color {
    var value: UInt64 = 0
    let digits = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
    Scanner(string: digits).scanHexInt64(&value)
    return Color(.sRGB,
                 red: Double((value >> 16) & 0xFF) / 255,
                 green: Double((value >> 8) & 0xFF) / 255,
                 blue: Double(value & 0xFF) / 255,
                 opacity: 1)
}

enum Palette {
    static let brandPrimary = hexColor("#382BC3")
    static let brandPrimaryLight = hexColor("#5C4FF4")
    static let brandSurfaceTranslucent = hexColor("#4B41C8")

    static let surfaceDefault = hexColor("#FFFFFF")
    static let surfaceMuted = hexColor("#F1F4F9")
    static let surfaceBrand = hexColor("#382BC3")
    static let surfaceChip = hexColor("#F9F9F9")

    static let tileBlue = hexColor("#0F2A85")
    static let tileGreen = hexColor("#3C694C")
    static let tileCream = hexColor("#FDF8F2")
    static let tileArch = hexColor("#F1F4FD")
    static let tileCreamBorder = hexColor("#E8D9BE")
    static let tileDark = hexColor("#1B2B22")
    static let tileOrange = hexColor("#C2410C")

    static let textPrimary = hexColor("#1A1A1A")
    static let textSecondary = hexColor("#6B7280")
    static let textOnDark = hexColor("#FFFFFF")
    static let textAccent = hexColor("#382BC3")
    static let textSuccess = hexColor("#15803D")
    static let textDanger = hexColor("#B31F1D")

    static let badgeDanger = hexColor("#B31F1D")
}
