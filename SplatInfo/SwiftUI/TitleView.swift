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
        HStack(spacing: 5) {
            Image(logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 40, height: 40)
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.largeTitle)
            Spacer()
        }
    }
}
