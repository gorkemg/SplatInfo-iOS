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
    var height: CGFloat = 100
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let image = stage.image {
                    Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)
                }
            }
            .cornerRadius(10.0)
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: height, maxHeight: height, alignment: .center)

            if isNameVisible {
                ImageOverlayText(text: stage.name)
            }
        }.aspectRatio(16/10, contentMode: .fit)
    }
}

struct ImageOverlayText: View {
    let text: String
    var body: some View {
        VStack {
            Text(text)
                .splat2Font(size: 10)
                .padding(.horizontal, 6.0)
        }
        .background(Color.black.opacity(0.5))
        .cornerRadius(8)
        .padding(4)
    }
}
