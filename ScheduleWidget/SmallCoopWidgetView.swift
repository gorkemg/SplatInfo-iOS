//
//  SmallCoopWidgetView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 31.10.20.
//

import SwiftUI

struct SmallCoopWidgetView : View {
    let event: CoopEvent
    let state: TimeframeActivityState

    var body: some View {
        ZStack(alignment: .topLeading) {

            Color.coopModeColor

            Image("bg-spots").resizable(resizingMode: .tile)

            GeometryReader { geometry in
                VStack(spacing: 0.0) {
                    if let image = event.stage.thumbImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                }.cornerRadius(10.0)
            }
            
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 0.0) {
                
                VStack(alignment: .leading, spacing: 0.0) {
                    HStack {
                        Image(event.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 20)
                        Text(event.modeName).splat2Font(size: 14).minimumScaleFactor(0.5).lineSpacing(0)
                    }
                    Text(event.stage.name).splat2Font(size: 10)
                }

                Spacer()
                
                VStack(alignment: .leading, spacing: 2.0) {
                    HStack {
                        ColoredActivityTextView(state: state)
                        RelativeTimeframeView(timeframe: event.timeframe, state: state)
                    }.splat2Font(size: 12)
                    
                    ActivityTimeFrameView(timeframe: event.timeframe, state: state).lineLimit(1).minimumScaleFactor(0.5)
                    HStack(spacing: 4.0) {
                        Group {
                            WeaponsList(weapons: event.weaponDetails)
                                .shadow(color: .black, radius: 2, x: 0.0, y: 1.0)
                                .frame(maxHeight: 24, alignment: .leading)
                        }
                        
                        Spacer()
                    }
                }.lineSpacing(0)
            }.padding(.horizontal, 10.0).padding(.vertical, 4.0)
        }.foregroundColor(.white)
    }
    
}

struct ColoredActivityTextView: View {
    let state: TimeframeActivityState
    var body: some View {
        HStack {
            Text(state.activityText)
        }.padding(.horizontal, 4.0).background(state.color).cornerRadius(5.0)
    }
}

extension TimeframeActivityState {
    
    var color : Color {
        switch self {
        case .active:
            return Color.coopModeColor
        case .soon:
            return Color.black
        case .over:
            return Color.gray.opacity(0.4)
        }
    }
    
}
