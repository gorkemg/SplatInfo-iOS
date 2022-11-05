//
//  CoopEntryView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 04.10.22.
//

import Foundation
import SwiftUI
import WidgetKit

struct CoopEntryView : View {
    let events: [CoopEvent]
    let eventTimeframes: [EventTimeframe]
    let date: Date
    let gear: CoopGear?
    let eventViewSettings: EventViewSettings

    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        Group {
            if let event = event {
                switch widgetFamily {
                case .systemSmall:
                    SmallCoopWidgetView(event: event, gear: gear, state: event.timeframe.state(date: date))
                case .systemMedium:
                    MediumCoopWidgetView(event: event, nextEvent: nextEvent, date: date, gear: gear)
                case .systemLarge:
                    LargeCoopWidgetView(events: events, eventTimeframes: otherTimeframes, date: date, gear: gear)
                case .systemExtraLarge:
                    LargeCoopWidgetView(events: events, eventTimeframes: otherTimeframes, date: date, gear: gear)
                case .accessoryCircular:
                    if #available(iOSApplicationExtension 16.0, *) {
                        #if os(watchOS)
                        CoopCircularWidgetView(event: event, date: date, displayStyle: .icon)
                        #else
                        CoopCircularWidgetView(event: event, date: date, displayStyle: .weapons)
                        #endif
                    }
                case .accessoryRectangular:
                    if #available(iOSApplicationExtension 16.0, *) {
                        CoopRectangularWidgetView(event: event, date: date, gear: gear)
                    }
                case .accessoryInline:
                    if #available(iOSApplicationExtension 16.0, *) {
                        CoopInlineWidgetView(event: event, date: date)
                    }
                #if os(watchOS)
                case .accessoryCorner:
                    Image(event.logoName).resizable().aspectRatio(contentMode: .fit).frame(maxHeight: 50)
                        .unredacted()
                        .widgetLabel {
                            ProgressView(timerInterval: event.timeframe.startDate...event.timeframe.endDate)
                                .tint(event.color)
                        }
                #endif
                @unknown default:
                    SmallCoopWidgetView(event: event, gear: gear, state: event.timeframe.state(date: date))
                }
            }else{
                Text("No event available")
            }
        }.environmentObject(eventViewSettings)
    }

    var event: CoopEvent? {
        return events.first
    }
    var nextEvent: CoopEvent? {
        if let currentEvent = self.event, let index = events.firstIndex(where: { $0 == currentEvent }), events.count > index+1 {
            return events[(index+1)]
        }
        return nil
    }
    
    var otherTimeframes: [EventTimeframe] {
        guard eventTimeframes.count > 2 else { return [] }
        let timeframes = Array(eventTimeframes[2...])
        return timeframes
    }
}
