//
//  LargerCoopWidgetView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 05.11.20.
//

import SwiftUI

struct LargerCoopWidgetView : View {
    let events: [CoopEvent]
    var eventTimeframes: [EventTimeframe]?
    var date: Date = Date()
    
    let style: LargerCoopWidgetStyle
    
    enum LargerCoopWidgetStyle {
        case large
        case narrow
    }
    

    var body: some View {
        ZStack(alignment: .topLeading) {

            Color.coopModeColor

            Image("bg-spots").resizable(resizingMode: .tile)
                        
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
            
            if style == .narrow, let event = events.first {
                ZStack(alignment: .topTrailing) {
                    Image(event.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 28)
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing).padding(.horizontal, 8).padding(.vertical, 4)
            }
            
            VStack(alignment: .leading, spacing: 2.0) {

                if style == .large {
                    HStack {
                        if let event = events.first {
                            Image(event.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 20)
                            Text(event.modeName).splat2Font(size: 14).minimumScaleFactor(0.5).lineSpacing(0)
                        }
                    }
                }
                    
                VStack(alignment: .leading, spacing: 2) {

                    ForEach(events.indices, id: \.self) { i in
                        CoopEventView(event: events[i], style: i == 0 && style == .large ? .large : .narrow)
                    }
                    
                    if let timeframes = otherTimeframes {
                        ForEach(timeframes, id: \.self) { timeframe in
                            TimeframeView(timeframe: timeframe, datesEnabled: true, fontSize: 8)
                        }
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal, 10.0).padding(.vertical, 4.0)

        }.foregroundColor(.white)
    }
    
    var otherTimeframes: [EventTimeframe] {
        guard let timeframes = eventTimeframes else { return [] }
        switch style {
        case .narrow:
            if events.count == 2 {
                return []
            }
            return Array(timeframes.prefix(1))
        case .large:
            return timeframes
        }
    }
    
    
//    var currentActivityTextView : some View {
//        HStack {
//            Text(currentActivityText)
//        }.padding(.horizontal, 4.0).background(currentActivityColor).cornerRadius(5.0)
//    }
//
//    var currentActivityText : String {
//        return event.timeframe.status(date: date).activityText
//    }
//    var currentActivityColor : Color {
//        switch event.timeframe.status(date: date) {
//        case .active:
//            return Color.coopModeColor
//        case .soon:
//            return Color.black
//        case .over:
//            return Color.gray
//        }
//    }
}
