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

    var state: TimeframeActivityState {
        return event.timeframe.state(date: date)
    }
    
    var body: some View {
        ZStack(alignment: .center) {

            Color.coopModeColor

            Image("bg-spots").resizable(resizingMode: .tile)
                       
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 4.0) {

                CoopEventView(event: event, style: .narrow, state: state, showTitle: true)

                if let nextEvent = nextEvent {
                    let state = nextEvent.timeframe.state(date: date)
                    CoopEventView(event: nextEvent, style: .sideBySide, state: state, showTitle: false)
                }
                
            }
            .padding(.horizontal, 4.0).padding(.vertical, 4.0)

        }.foregroundColor(.white)
    }
}
