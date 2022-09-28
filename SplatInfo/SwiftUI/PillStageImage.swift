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

class ImageQuality: ObservableObject {
    @Published var thumbnail: Bool = false
}

struct StageImage: View {
    let stage : Stage
    var namePosition: NamePosition = .bottom
    @EnvironmentObject var imageQuality: ImageQuality
    
    enum NamePosition {
        case hidden
        case top
        case bottom
    }

    var width: CGFloat?
    var height: CGFloat?

    var body: some View {
            ZStack(alignment: .bottomTrailing) {


                if let image = (imageQuality.thumbnail ? stage.thumbImage : stage.image) {
                    Image(uiImage: image).centerCropped()//.scaledToFill()
                        .frame(maxWidth: width, maxHeight: height, alignment: .center)
                }else{
                    AsyncImage(url: stage.imageUrl) { image in
                        image.centerCropped()//.scaledToFill()
                            .frame(maxWidth: width, maxHeight: height, alignment: .center)
                    } placeholder: {
                        Color.black
                    }
                }

                VStack {
                    if namePosition == .top {
                        ImageOverlayText(text: stage.name)
                            .padding(.horizontal, 4.0)
                            .padding(.vertical, 2.0)
                    }
                    
                    Spacer()

                    if namePosition == .bottom {
                        ImageOverlayText(text: stage.name)
                            .padding(.horizontal, 4.0)
                            .padding(.vertical, 2.0)
                    }
                }
            }
    }

}

struct PillStageImage: View {
    let stage : Stage
    var namePosition: StageImage.NamePosition = .bottom
    @EnvironmentObject var imageQuality: ImageQuality

    var width: CGFloat?
    var height: CGFloat?

    var body: some View {
            StageImage(stage: stage, namePosition: namePosition, width: width, height: height)
            .cornerRadius(10)
            .clipShape(ContainerRelativeShape())
            .shadow(color: .black, radius: 2, x: 0.0, y: 1.0)
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
