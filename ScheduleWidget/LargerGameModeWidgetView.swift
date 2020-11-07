//
//  LargerGameModeWidgetView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 05.11.20.
//

import SwiftUI

struct LargerGameModeWidgetView : View {
    let event: GameModeEvent
    var nextEvent: GameModeEvent? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {

            event.mode.type.color

            Image("splatoon-card-bg").resizable(resizingMode: .tile)

            GeometryReader { geometry in
                VStack(spacing: 0.0) {
                    ForEach(event.stages, id: \.id) { stage in
                        if let image = stage.image {
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
                    HStack {
                        Image(event.mode.type.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 20)
                        Text(event.rule.name).splat2Font(size: 14).minimumScaleFactor(0.5)
                    }
                }
                                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0.0) {
                    if let next = nextEvent {
                        Text(event.mode.type != .regular ? next.rule.name : "Changes")
                        + relativeTimeText(event: next)
                    }
                }.splat2Font(size: 10).lineLimit(1).minimumScaleFactor(0.5)
            }.padding(.horizontal, 10.0).padding(.vertical, 4)
        }
    }

    func relativeTimeText(event: GameModeEvent) -> Text {
        switch event.timeframe.status(date: Date()) {
        case .active:
            return Text(" since ") + Text(event.timeframe.startDate, style: .relative)
        case .soon:
            return Text(" in ") + Text(event.timeframe.startDate, style: .relative)
        case .over:
            return Text(" ended ") + Text(event.timeframe.endDate, style: .relative) + Text(" ago")
        }
    }
}
