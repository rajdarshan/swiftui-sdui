//
//  AvailableWidth.swift
//  SwiftUISDUI
//
//  design_spec.md §2.6 / §4.1 — measured once at the page container, injected
//  via @Environment. Never a nested GeometryReader inside a rail/grid/lazy row.
//  Set with .onGeometryChange(for:of:action:) (iOS 18), not GeometryReader.
//

import SwiftUI

private struct AvailableWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var availableWidth: CGFloat {
        get { self[AvailableWidthKey.self] }
        set { self[AvailableWidthKey.self] = newValue }
    }
}

extension View {
    func measuringAvailableWidth(into width: Binding<CGFloat>) -> some View {
        onGeometryChange(
            for: CGFloat.self,
            of: { $0.size.width },
            action: { newWidth in width.wrappedValue = newWidth }
        )
    }
}
