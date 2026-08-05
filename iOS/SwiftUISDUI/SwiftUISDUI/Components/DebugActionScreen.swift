//
//  DebugActionScreen.swift
//  SwiftUISDUI
//
//  COMPONENTS.md §6.2: "All navigate and openSheet actions resolve to a
//  single DebugActionScreen displaying type, target, and params. No real
//  destinations are built." Presented as a sheet by the owning screen
//  (design_spec.md §3.1's ActionHandler → DebugActionScreen).
//

import SwiftUI

struct DebugActionScreen: View {
    let action: Action

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sectionGap) {
            Text("Debug Action")
                .font(Typography.sectionTitle)
                .foregroundStyle(Palette.textPrimary)

            VStack(alignment: .leading, spacing: Spacing.sectionHeaderToContent) {
                row(label: "type", value: action.type)
                row(label: "target", value: action.target)
                if action.params.isEmpty {
                    row(label: "params", value: "—")
                } else {
                    ForEach(action.params.sorted(by: { $0.key < $1.key }), id: \.key) { entry in
                        row(label: "params.\(entry.key)", value: entry.value)
                    }
                }
            }

            Spacer()
        }
        .padding(Spacing.pageMargin)
    }

    private func row(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(Typography.caption)
                .foregroundStyle(Palette.textSecondary)
            Text(value)
                .font(Typography.body)
                .foregroundStyle(Palette.textPrimary)
        }
    }
}
