//
//  LargeCoopWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 14.12.20.
//

import SwiftUI

struct LargeCoopWidgetView : View {
    let events: [CoopEvent]
    var eventTimeframes: [EventTimeframe]?
    let date: Date

    var body: some View {
        ZStack(alignment: .topLeading) {

            Color.coopModeColor

            Image("bg-spots").resizable(resizingMode: .tile)
                        
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 2.0) {

                HStack {
                    if let event = events.first {
                        Image(event.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 20)
                        Text(event.modeName).splat2Font(size: 14).minimumScaleFactor(0.5).lineSpacing(0)
                    }
                }

                GeometryReader { innerGeo in

                    VStack(alignment: .leading, spacing: 8) {

                        ForEach(events.indices, id: \.self) { i in
                            let event = events[i]
                            let state = event.timeframe.state(date: date)
                            CoopEventView(event: event, style: i == 0 ? .large : .narrow, state: state)
                        }
                        
                        VStack {
                            if let timeframes = otherTimeframes {
                                ForEach(timeframes, id: \.self) { timeframe in
                                    TimeframeView(timeframe: timeframe, datesStyle: .always, fontSize: 12)
                                }
                            }
                        }.padding(2)
                        
                        Spacer()
                        
                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)

                }
                
            }.padding(.horizontal, 10.0).padding(.vertical, 4.0)

        }.foregroundColor(.white)
    }
    
    var otherTimeframes: [EventTimeframe] {
        guard let timeframes = eventTimeframes else { return [] }
        return timeframes
    }
}
