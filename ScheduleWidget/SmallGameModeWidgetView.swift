//
//  SmallGameModeWidgetView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 31.10.20.
//

import SwiftUI

struct SmallGameModeWidgetView : View {
    let event: GameModeEvent
    var nextEvent: GameModeEvent? = nil
    let date: Date

    var body: some View {
        ZStack(alignment: .topLeading) {

            //event.mode.color

            Image("splatoon-card-bg").resizable(resizingMode: .tile)

            GeometryReader { geometry in
                VStack(spacing: 0.0) {
                    ForEach(event.stages, id: \.id) { stage in
                        if let image = stage.thumbImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height/2)
                                .clipped()
                        }
                    }
                }.cornerRadius(10.0)
            }
            
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 0.0) {
                
                VStack(alignment: .leading, spacing: 0.0) {
                    GameModeEventTitleView(event: event)
                }
                                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0.0) {
                    if let next = nextEvent {
                        Text(!event.mode.isTurfWar ? next.rule.name : "Changes")
                            + next.timeframe.relativeTimeText(date: date)
                    }
                }.splat2Font(size: 10).lineLimit(1).minimumScaleFactor(0.5)
            }.padding(.horizontal, 10.0).padding(.vertical, 8.0)
        }
    }
}
