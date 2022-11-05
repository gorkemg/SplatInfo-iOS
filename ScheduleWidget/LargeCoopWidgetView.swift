//
//  LargeCoopWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 14.12.20.
//

import SwiftUI

struct LargeCoopWidgetView : View {
    let events: [CoopEvent]
    var maxVisibleEvents: Int = 4
    var eventTimeframes: [EventTimeframe]?
    let date: Date
    let gear: CoopGear?

    @EnvironmentObject var eventViewSettings: EventViewSettings

    var topSettings: EventViewSettings {
        let settings = self.eventViewSettings.copy()
        settings.settings.showTitle = true
        settings.settings.showMonthlyGear = true
        return settings
    }

    var bottomSettings: EventViewSettings {
        let settings = self.eventViewSettings.copy()
        settings.settings.showTitle = false
        settings.settings.showMonthlyGear = false
        return settings
    }

    var body: some View {
        ZStack(alignment: .topLeading) {

            Color.coopModeColor

            Image("bg-spots").resizable(resizingMode: .tile)
                        
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 2.0) {

                VStack(alignment: .leading, spacing: 8.0) {

                    ForEach(events.prefix(maxVisibleEvents).indices, id: \.self) { i in
                        let event = events[i]
                        let state = event.timeframe.state(date: date)
                        CoopEventView(event: event, gear: gear, style: i == 0 ? .large : .sideBySide, state: state)
                            .environmentObject(i == 0 ? topSettings : bottomSettings)
                    }
                    
                    VStack {
                        if let timeframes = otherTimeframes {
                            ForEach(timeframes, id: \.self) { timeframe in
                                TimeframeView(timeframe: timeframe, datesStyle: .always, fontSize: 12)
                            }
                        }
                    }.padding(2)
                                            
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                
            }.padding(.horizontal, 10.0).padding(.vertical, 8.0)

        }.foregroundColor(.white)
    }
    
    var otherTimeframes: [EventTimeframe] {
        guard let timeframes = eventTimeframes else { return [] }
        return timeframes
    }
}
