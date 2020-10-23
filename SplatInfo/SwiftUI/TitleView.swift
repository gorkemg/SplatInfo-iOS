//
//  TitleView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct TitleView: View {
    let title: String
    let logoName: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(logoName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .shadow(color: .black, radius: 1, x: 0.0, y: 1)
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .splat1Font(size: 30)
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
