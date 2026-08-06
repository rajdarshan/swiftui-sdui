//
//  ScrollJankProbe.swift
//  SwiftUISDUI
//
//  design_spec.md §3.4: scroll perf is measured across the harness's single
//  scroll pass from TTI to the last section's first commit — the same pass
//  that produces ttiMs and fullPageWallMs, so there is no second scroll and
//  no extra app launch. A frame's budget is read from CADisplayLink's own
//  targetTimestamp - timestamp rather than assumed to be a fixed 60Hz, since
//  these are ProMotion, variable-refresh-rate displays.
//
//  ScrollFrameAccumulator is split out as a pure function over frame
//  intervals so the drop-counting logic gets an executed unit test without
//  a run loop, mirroring DeviceContext's split between pure functions and
//  the system-call wrapper (Performance/PerformanceSample.swift).
//

import QuartzCore

struct ScrollFrameStats: Equatable, Sendable {
    let frameCount: Int
    let droppedFrames: Int
    let worstFrameMs: Double
    let hitchMs: Double
}

enum ScrollFrameAccumulator {
    struct Totals: Equatable {
        var droppedFrames: Int = 0
        var hitchMs: Double = 0
        var worstFrameMs: Double = 0
    }

    /// A frame counts as dropped when its actual duration exceeds its
    /// expected per-frame budget by more than 50%. `expectedMs` is the
    /// current frame's own budget (from CADisplayLink), not a global
    /// constant, so this adapts to 120Hz/60Hz/24Hz automatically.
    static func accumulate(expectedMs: Double, actualMs: Double, into totals: inout Totals) {
        guard expectedMs > 0 else { return }
        if actualMs > expectedMs * 1.5 {
            let extraFrames = Int((actualMs / expectedMs).rounded(.down)) - 1
            totals.droppedFrames += max(extraFrames, 0)
            totals.hitchMs += actualMs - expectedMs
        }
        totals.worstFrameMs = max(totals.worstFrameMs, actualMs)
    }
}

/// Constructed only when `PerformanceMarks` is enabled (Performance/PerformanceMarks.swift)
/// — a normal launch never creates one.
@MainActor
final class ScrollJankProbe: NSObject {
    private var displayLink: CADisplayLink?
    private var lastTimestamp: CFTimeInterval?
    private var frameCount = 0
    private var totals = ScrollFrameAccumulator.Totals()

    func start() {
        guard displayLink == nil else { return }
        frameCount = 0
        lastTimestamp = nil
        totals = ScrollFrameAccumulator.Totals()
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() -> ScrollFrameStats {
        displayLink?.invalidate()
        displayLink = nil
        return ScrollFrameStats(
            frameCount: frameCount,
            droppedFrames: totals.droppedFrames,
            worstFrameMs: totals.worstFrameMs,
            hitchMs: totals.hitchMs
        )
    }

    @objc
    private func tick(_ link: CADisplayLink) {
        frameCount += 1
        defer { lastTimestamp = link.timestamp }
        guard let lastTimestamp else { return }
        let expectedMs = (link.targetTimestamp - link.timestamp) * 1000
        let actualMs = (link.timestamp - lastTimestamp) * 1000
        ScrollFrameAccumulator.accumulate(expectedMs: expectedMs, actualMs: actualMs, into: &totals)
    }
}
