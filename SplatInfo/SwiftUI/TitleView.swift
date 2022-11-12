//
//  TitleView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct TitleView: View {
    let title: String
    private var logoName: String?
    private var uiImage: UIImage?
    var titleFontSize: CGFloat = 30
    var logoSize: CGSize = CGSize(width: 40, height: 40)
    
    init(title: String, logoName: String, titleFontSize: CGFloat? = nil, logoSize: CGSize? = nil) {
        self.title = title
        self.logoName = logoName
        if let titleFontSize {
            self.titleFontSize = titleFontSize
        }
        if let logoSize {
            self.logoSize = logoSize
        }
    }
    
    init(title: String, uiImage: UIImage, titleFontSize: CGFloat? = nil, logoSize: CGSize? = nil) {
        self.title = title
        self.uiImage = uiImage
        if let titleFontSize {
            self.titleFontSize = titleFontSize
        }
        if let logoSize {
            self.logoSize = logoSize
        }
    }
    
    var image: Image {
        if let logoName {
            return Image(logoName)
        }else if let uiImage {
            return Image(uiImage: uiImage)
        }
        return Image("")
    }
    
    
    var body: some View {
        HStack(spacing: 10) {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: logoSize.width, height: logoSize.height)
                .shadow(color: .black, radius: 1, x: 0.0, y: 1)
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .splat1Font(size: titleFontSize)
            Spacer()
        }
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(title: "Hello World", logoName: "mr-grizz-logo")
            .previewLayout(.sizeThatFits)
    }
}
