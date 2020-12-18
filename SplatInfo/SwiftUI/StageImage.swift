//
//  StageImage.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}


struct StageImage: View {
    let stage : Stage
    var isNameVisible: Bool = true
    var useThumbnailQuality: Bool = false
    var width: CGFloat?
    var height: CGFloat?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                if let image = (useThumbnailQuality ? stage.thumbImage : stage.image) {
                    Image(uiImage: image).centerCropped().scaledToFill()
                        .frame(maxWidth: width, maxHeight: height, alignment: .center)
                }

                if isNameVisible {
                    ImageOverlayText(text: stage.name)
                        .padding(0)
                }
            }
            .cornerRadius(10.0)
        }
        
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
