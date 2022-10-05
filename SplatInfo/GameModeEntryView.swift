//
//  GameModeEntryView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 04.10.22.
//

import Foundation
import SwiftUI
import WidgetKit

struct GameModeEntryView : View {
    let gameMode: GameModeType
    let events: [GameModeEvent]
    let date: Date                  // Widget update date
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    var body: some View {
        if let event = event {
            switch widgetFamily {
            case .systemSmall:
                SmallGameModeWidgetView(event: event, nextEvent: nextEvent, date: date)
            case .systemMedium:
                MediumGameModeWidgetView(event: event, nextEvent: nextEvent, date: date)
            case .systemLarge:
                LargeGameModeWidgetView(event: event, nextEvents: Array(nextEvents.prefix(3)), date: date)
            case .systemExtraLarge:
                LargeGameModeWidgetView(event: event, nextEvents: Array(nextEvents.prefix(3)), date: date)
            case .accessoryCircular:
                if #available(iOSApplicationExtension 16.0, *) {
                    IconCircularWidgetView(startDate: event.timeframe.startDate, endDate: event.timeframe.endDate, imageName: event.rule.logoName, progressTintColor: event.mode.color)
                }else{
                    Text("No event available").splat1Font(size: 20)
                }
            case .accessoryRectangular:
                if #available(iOSApplicationExtension 16.0, *) {
                    GameModeRectangularWidgetView(event: event, date: date)
                }else{
                    Text("No event available").splat1Font(size: 20)
                }
            case .accessoryInline:
                if #available(iOSApplicationExtension 16.0, *) {
                    GameModeInlineWidgetView(event: event, date: date)
                }else{
                    Text("No event available").splat1Font(size: 20)
                }
            #if os(watchOS)
            case .accessoryCorner:
                Image(event.rule.logoNameSmall).resizable().aspectRatio(contentMode: .fit).frame(maxHeight: 50)
                    .widgetLabel {
                    ProgressView(timerInterval: event.timeframe.startDate...event.timeframe.endDate)
                }
            #endif
            @unknown default:
                Text("No event available").splat1Font(size: 20)
            }
        }else{
            Text("No event available").splat1Font(size: 20)
        }
    }
    
    var event: GameModeEvent? {
        return events.first
    }
    var nextEvent: GameModeEvent? {
        if let currentEvent = self.event, let index = events.firstIndex(where: { $0 == currentEvent }), events.count > index+1 {
            return events[(index+1)]
        }
        return nil
    }
    var nextEvents: [GameModeEvent] {
        if events.count == 0 { return [] }
        return Array(events[1...])
    }
}
