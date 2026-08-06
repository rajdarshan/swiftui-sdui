//
//  SectionContainer.swift
//  SwiftUISDUI
//
//  Shared wrapper for every section type: optional SectionHeader above the
//  content, optional style.background painting the whole band.
//  COMPONENTS.md §6.
//
//  `perfIndex`/`perfSectionCount` are optional performance-harness hooks
//  (design_spec.md §3.4): when present, this container times its own
//  `content()` build and reports it via `PerformanceMarks.recordSectionBuild`,
//  and — only for the last section, so the FirstCommitProbe overhead isn't
//  paid 13 times — reports its first commit as the page's full-page mark.
//  `@Environment` isn't available inside `init`, so the build duration is
//  measured there and handed to `marks` in `body` instead, matching the
//  existing pattern of `SDUIPageView`/`StaticHomeView` recording T2 there.
//  Absent on every call site outside the two screens, and a no-op even when
//  present unless `PerformanceMarks` is enabled.
//

import SwiftUI

struct SectionContainer<Content: View>: View {
    let header: SectionHeader?
    let style: Style?
    let content: Content
    private let perfIndex: Int?
    private let perfSectionCount: Int?
    private let contentBuildMs: Double

    @Environment(\.performanceMarks) private var marks

    init(
        header: SectionHeader? = nil,
        style: Style? = nil,
        perfIndex: Int? = nil,
        perfSectionCount: Int? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.style = style
        self.perfIndex = perfIndex
        self.perfSectionCount = perfSectionCount
        if perfIndex != nil {
            let start = ContinuousClock.now
            self.content = content()
            contentBuildMs = (ContinuousClock.now - start).milliseconds
        } else {
            self.content = content()
            contentBuildMs = 0
        }
    }

    private var isLastSection: Bool {
        guard let perfIndex, let perfSectionCount else { return false }
        return perfIndex == perfSectionCount - 1
    }

    var body: some View {
        if let perfIndex {
            marks.recordSectionBuild(index: perfIndex, durationMs: contentBuildMs)
        }
        if isLastSection {
            return AnyView(sectionBody.measuredFirstCommit { instant in marks.recordLastSectionCommit(instant) })
        } else {
            return AnyView(sectionBody)
        }
    }

    private var sectionBody: some View {
        VStack(alignment: .leading, spacing: Spacing.sectionHeaderToContent) {
            if let header {
                HStack(alignment: .firstTextBaseline, spacing: Spacing.sectionHeaderToContent) {
                    Text(header.title)
                        .font(Typography.sectionTitle)
                        .foregroundStyle(style?.background == nil ? Palette.textPrimary : Palette.textOnDark)
                    if let badge = header.badge {
                        BadgeView(badge: badge)
                    }
                    Spacer()
                    if let trailing = header.trailing {
                        ButtonSpecView(spec: trailing)
                    }
                }
                .padding(.horizontal, Spacing.pageMargin)
            }
            content
        }
        .padding(.vertical, Spacing.sectionHeaderToContent)
        .background(style?.background ?? .clear)
    }
}
