//
//  Schedule.swift
//  Schedule
//
//  Created by Görkem Güclü on 23.10.20.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct SplatInfoWidgetBundle: WidgetBundle {
    
    // MARK: - View
    @WidgetBundleBuilder
    var body: some Widget {
        Splatoon3ScheduleWidget()
        Splatoon2ScheduleWidget()
    }
}

struct GameModeEntryView : View {
    let gameMode: GameModeType
    let events: [GameModeEvent]
    let date: Date
    
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
                    CircularWidgetView(startDate: event.timeframe.startDate, endDate: event.timeframe.endDate, imageName: event.mode.logoNameSmall)
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


struct CoopEntryView : View {
    let events: [CoopEvent]
    let eventTimeframes: [EventTimeframe]
    let date: Date

    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            if let event = event {
                SmallCoopWidgetView(event: event, state: event.timeframe.state(date: date))
            }else{
                Text("No event available")
            }
        case .systemMedium:
            if let event = event {
                MediumCoopWidgetView(event: event, nextEvent: nextEvent, date: date)
            }else{
                Text("No event available")
            }
        case .systemLarge:
            LargeCoopWidgetView(events: events, eventTimeframes: otherTimeframes, date: date)
        case .systemExtraLarge:
            LargeCoopWidgetView(events: events, eventTimeframes: otherTimeframes, date: date)
        case .accessoryCircular:
            if #available(iOSApplicationExtension 16.0, *) {
                if let startDate = event?.timeframe.startDate, let endDate = event?.timeframe.endDate {
                    CircularWidgetView(startDate: startDate, endDate: endDate, imageName: event?.logoName)
                } else {
                    Image(systemName: "trash")
                     }
            }else{
                Text("NO")
            }
        case .accessoryRectangular:
            if #available(iOSApplicationExtension 16.0, *) {
                if let event = event {
                    CoopRectangularWidgetView(event: event, date: date)
                }
            }
        case .accessoryInline:
            if #available(iOSApplicationExtension 16.0, *) {
                if let event = event {
                    CoopInlineWidgetView(event: event, date: date)
                }
            }
        @unknown default:
            if let event = event {
                SmallCoopWidgetView(event: event, state: event.timeframe.state(date: date))
            }else{
                Text("No event available")
            }
        }
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

//struct Schedule_Previews: PreviewProvider {
//
//    static let schedule = Splatoon2.Schedule.example
//
//    static var regularEvents : [GameModeEvent] {
//        return schedule.regular.events
//    }
//
//    static var rankedEvents : [GameModeEvent] {
//        return schedule.ranked.events
//    }
//
//    static var leagueEvents : [GameModeEvent] {
//        return schedule.league.events
//    }
//
//    static var intent : Splatoon2_ScheduleIntent {
//        return Splatoon2_ScheduleIntent()
//    }
//
//    static var intentWithDisplayNext : Splatoon2_ScheduleIntent {
//        let intent = Splatoon2_ScheduleIntent()
//        intent.displayNext = true
//        return intent
//    }
//
//
//    static var previews: some View {
//
//        Splatoon2TimelineProvider.ScheduleEntryView(entry: Splatoon2TimelineProvider.GameModeEntry(date: Date(), events: .gameModeEvents(events: regularEvents), configuration: Splatoon2_ScheduleIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//
////        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.detailedEvents, timeframes: schedule.coop.eventTimeframes), configuration: ConfigurationIntent()))
////            .previewContext(WidgetPreviewContext(family: .systemLarge))
//
//        //        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.detailedEvents, timeframes: schedule.coop.eventTimeframes), configuration: ConfigurationIntent()))
////            .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
//
//    }
//}
