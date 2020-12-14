//
//  StageImage.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct StageImage: View {
    let stage : Stage
    var isNameVisible: Bool = true
    var useThumbnailQuality: Bool = true
    var width: CGFloat?
    var height: CGFloat?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let image = (useThumbnailQuality ? stage.thumbImage : stage.image) {
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
                }
                if isNameVisible {
                    ImageOverlayText(text: stage.name)
                        .padding(0)
                }
            }
            .padding(0)
            .frame(maxWidth: width, maxHeight: height, alignment: .bottomTrailing)
        }
        .padding(0)
        .clipped()
        .cornerRadius(10.0)
    }
}

struct ImageOverlayText: View {
    let text: String
    var body: some View {
        VStack {
            Text(text)
                .splat2Font(size: 10)
                .padding(.horizontal, 4.0)
                .lineLimit(1)
        }
        .background(Color.black.opacity(0.5))
        .cornerRadius(6)
        .padding(2)
    }
}
