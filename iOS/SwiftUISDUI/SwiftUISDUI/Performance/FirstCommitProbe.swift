//
//  FirstCommitProbe.swift
//  SwiftUISDUI
//
//  design_spec.md §3.4: T3 is CATransaction completion on first content
//  commit. Shared by both screens via .measuredFirstCommit(onCommit:) so
//  the mechanism is provably identical on both variants (design_spec.md
//  §5: "Rendering the same header in both variants is required for T0-T3
//  to be comparable"). No CATransaction.begin()/commit() here deliberately
//  — viewDidLayoutSubviews() already runs inside the transaction that
//  contains this screen's first real content commit; opening a fresh one
//  would register the completion block against the wrong transaction.
//

import SwiftUI
import UIKit

private final class ProbeViewController: UIViewController {
    var onCommit: (@Sendable (ContinuousClock.Instant) -> Void)?
    private var hasFiredCommit = false

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !hasFiredCommit else { return }
        hasFiredCommit = true
        let onCommit = onCommit
        CATransaction.setCompletionBlock {
            let instant = ContinuousClock.now
            Task { @MainActor in onCommit?(instant) }
        }
    }
}

private struct FirstCommitProbe: UIViewControllerRepresentable {
    let onCommit: @Sendable (ContinuousClock.Instant) -> Void

    func makeUIViewController(context: Context) -> ProbeViewController {
        let controller = ProbeViewController()
        controller.onCommit = onCommit
        return controller
    }

    func updateUIViewController(_ uiViewController: ProbeViewController, context: Context) {}
}

extension View {
    func measuredFirstCommit(onCommit: @escaping @Sendable (ContinuousClock.Instant) -> Void) -> some View {
        background(FirstCommitProbe(onCommit: onCommit))
    }
}
