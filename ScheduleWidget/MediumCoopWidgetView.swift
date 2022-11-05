//
//  MediumCoopWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 14.12.20.
//

import SwiftUI

struct MediumCoopWidgetView : View {
    let event: CoopEvent
    let nextEvent: CoopEvent?
    let date: Date
    let gear: CoopGear?

    var state: TimeframeActivityState {
        return event.timeframe.state(date: date)
    }
    
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
        ZStack(alignment: .center) {

            Color.coopModeColor

            Image("bg-spots").resizable(resizingMode: .tile)
                       
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 8.0) {

                CoopEventView(event: event, gear: gear, style: .narrow, state: state)
                    .environmentObject(topSettings)

                if let nextEvent = nextEvent {
                    let state = nextEvent.timeframe.state(date: date)
                    CoopEventView(event: nextEvent, gear: gear, style: .sideBySide, state: state)
                        .environmentObject(bottomSettings)
                }
                
            }
            .padding(.horizontal, 8.0).padding(.vertical, 8.0)

        }.foregroundColor(.white)
    }
}
