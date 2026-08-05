//
//  CachedImage.swift
//  SwiftUISDUI
//
//  Custom cached async image loader. AsyncImage is prohibited — no cache,
//  refetches on redraw. design_spec.md §4.1.
//
//  Three phases: `loading` shows the placeholder at the declared aspect so
//  layout doesn't shift when the image arrives; `failed` collapses the slot
//  to zero size so text-only content still renders (COMPONENTS.md §10).
//

import SwiftUI

struct CachedImage: View {
    let imageRef: ImageRef

    @State private var phase: Phase = .loading

    private enum Phase {
        case loading
        case loaded(UIImage)
        case failed
    }

    var body: some View {
        Group {
            switch phase {
            case .loading:
                Rectangle()
                    .fill(imageRef.placeholder)
                    .aspectRatio(imageRef.aspect.map { CGFloat($0) }, contentMode: .fill)
            case .loaded(let uiImage):
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .aspectRatio(imageRef.aspect.map { CGFloat($0) }, contentMode: .fill)
            case .failed:
                Color.clear.frame(width: 0, height: 0)
            }
        }
        .clipped()
        .task(id: imageRef.url) {
            await load()
        }
    }

    private func load() async {
        guard let url = URL(string: imageRef.url) else {
            phase = .failed
            return
        }
        if let cached = await ImageCache.shared.image(for: url) {
            phase = .loaded(cached)
            return
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let uiImage = UIImage(data: data) else {
            phase = .failed
            return
        }
        await ImageCache.shared.store(uiImage, for: url)
        phase = .loaded(uiImage)
    }
}
