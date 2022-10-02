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
                    if let image = event.stage.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                }.cornerRadius(10.0)
            }
                        
            VStack(alignment: .leading, spacing: 0.0) {
                
                VStack(alignment: .leading, spacing: 0.0) {
                    CoopEventTitleView(event: event, gameLogoPosition: .trailing)
                    Text(event.stage.name).splat2Font(size: 10)
                }

                Spacer()
                
                VStack(alignment: .leading, spacing: 2.0) {
                    HStack {
                        if event.game == .splatoon2 {
                            ColoredActivityTextView(state: state)
                        }
                        RelativeTimeframeView(timeframe: event.timeframe, state: state)
                    }.splat2Font(size: 12)
                    
                    ActivityTimeFrameView(timeframe: event.timeframe, state: state).lineLimit(1).minimumScaleFactor(0.5)
                    HStack(spacing: 4.0) {
                        Group {
                            WeaponsList(weapons: event.weaponDetails)
                                .frame(maxHeight: 24.0)
                                .padding(.horizontal, 8.0)
                                .background(.ultraThinMaterial.opacity(0.9))
                                .cornerRadius(8.0)
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
                .shadow(color: .black, radius: 1.0, x: 0.0, y: 1.0)
        }.padding(.horizontal, 4.0).background(state.color).cornerRadius(5.0)
    }
}

extension TimeframeActivityState {
    
    var color : Color {
        switch self {
        case .active:
            return Color.green
        case .soon:
            return Color.black
        case .over:
            return Color.black
        }
    }
    
}
