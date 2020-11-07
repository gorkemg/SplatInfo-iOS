//
//  SmallCoopWidgetView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 31.10.20.
//

import SwiftUI

struct SmallCoopWidgetView : View {
    let event: CoopEvent
    var date: Date = Date()

    var body: some View {
        ZStack(alignment: .topLeading) {

            event.color

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
                        currentActivityTextView
                        RelativeTimeframeView(timeframe: event.timeframe, date: date)
                    }.splat2Font(size: 12)
                    
                    ActivityTimeFrameView(event: event, date: date).lineLimit(1).minimumScaleFactor(0.5)
                    HStack(spacing: 4.0) {
                        Group {
                            WeaponsList(event: event)
                                .shadow(color: .black, radius: 2, x: 0.0, y: 1.0)
                                .frame(maxHeight: 24, alignment: .leading)
                        }
                        
                        Spacer()
                    }
                }.lineSpacing(0)
            }.padding(.horizontal, 10.0).padding(.vertical, 4.0)
        }.foregroundColor(.white)
    }
    
    var currentActivityTextView : some View {
        HStack {
            Text(currentActivityText)
        }.padding(.horizontal, 4.0).background(currentActivityColor).cornerRadius(5.0)
    }
    
    var currentActivityText : String {
        return event.timeframe.status(date: date).activityText
    }
    var currentActivityColor : Color {
        switch event.timeframe.status(date: date) {
        case .active:
            return Color.coopModeColor
        case .soon:
            return Color.black
        case .over:
            return Color.gray
        }
    }
}

extension TimeframeActivityStatus {
    
    var color : Color {
        switch self {
        case .active:
            return Color.coopModeColor
        case .soon:
            return Color.black
        case .over:
            return Color.gray
        }
    }
    
}
