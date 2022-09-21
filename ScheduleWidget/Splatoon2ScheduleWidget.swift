//
//  Schedule.swift
//  Schedule
//
//  Created by Görkem Güclü on 23.10.20.
//

import WidgetKit
import SwiftUI
import Intents

extension ConfigurationIntent {
    
    var isDisplayNext: Bool {
        guard let next = self.displayNext else { return false }
        return next.boolValue
    }
    
}

struct GameModeEntry: TimelineEntry {
    let date: Date
    let events: GameModeEvents
    let configuration: ConfigurationIntent
}

enum GameModeEvents {
    case gameModeEvents(events: [Splatoon2.GameModeEvent])
    case coopEvents(events: [CoopEvent], timeframes: [EventTimeframe])
}


struct ScheduleEntryView : View {
    var entry: Splatoon2TimelineProvider.Entry
    
    var gameModeType : Splatoon2.GameModeType {
        switch entry.configuration.scheduleType {
        case .unknown, .salmonRun, .regular:
            return .regular
        case .ranked:
            return .ranked
        case .league:
            return .league
        }
    }
    
    var body: some View {
        switch entry.events {
        case .gameModeEvents(_):
            GameModeEntryView(gameMode: gameModeType, events: gameModeEvents, date: entry.date).foregroundColor(.white).environmentObject(imageQuality)
        case .coopEvents(events: _, timeframes: let timeframes):
            CoopEntryView(events: coopEvents, eventTimeframes: timeframes, date: entry.date).foregroundColor(.white).environmentObject(imageQuality)
        }
    }
    
    var imageQuality : ImageQuality {
        let quality = ImageQuality()
        quality.thumbnail = true
        return quality
    }
    
    
    var displayNext: Bool {
        guard let displayNext = entry.configuration.displayNext else { return false }
        return displayNext.boolValue
    }

    var gameModeEvents: [Splatoon2.GameModeEvent] {
        switch entry.events {
        case .gameModeEvents(events: let events):
            if displayNext, events.count > 1 { return Array(events.suffix(from: 1)) }
            return events
        default:
            break
        }
        return []
    }

    var coopEvents: [CoopEvent] {
        switch entry.events {
        case .coopEvents(events: let events, timeframes: _):
            if displayNext, events.count > 1 { return Array(events.suffix(from: 1)) }
            return events
        default:
            break
        }
        return []
    }

}

struct GameModeEntryView : View {
    let gameMode: Splatoon2.GameModeType
    let events: [Splatoon2.GameModeEvent]
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
                    CircularWidgetView(startDate: event.timeframe.startDate, endDate: event.timeframe.endDate, imageName: event.mode.name)
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
    
    var event: Splatoon2.GameModeEvent? {
        return events.first
    }
    var nextEvent: Splatoon2.GameModeEvent? {
        if let currentEvent = self.event, let index = events.firstIndex(where: { $0 == currentEvent }), events.count > index+1 {
            return events[(index+1)]
        }
        return nil
    }
    var nextEvents: [Splatoon2.GameModeEvent] {
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

@main
struct SplatInfoWidgetBundle: WidgetBundle {
    
    // MARK: - View
    @WidgetBundleBuilder
    var body: some Widget {
        Splatoon3ScheduleWidget()
        Splatoon2ScheduleWidget()
    }
}

struct Splatoon2ScheduleWidget: Widget {
    let kind: String = "Splatoon2ScheduleWidget"

    var supportedWidgetFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryInline, .accessoryRectangular]
        }else{
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Splatoon2TimelineProvider()) { entry in
            ScheduleEntryView(entry: entry)
        }
        .supportedFamilies(supportedWidgetFamilies)
        .configurationDisplayName("Splatoon 2")
        .description("Splatoon 2 Schedules")
    }
}

struct Splatoon3ScheduleWidget: Widget {
    let kind: String = "Splatoon3ScheduleWidget"

    var supportedWidgetFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryInline, .accessoryRectangular]
        }else{
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }

    var body: some WidgetConfiguration {
        
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Splatoon2TimelineProvider()) { entry in
            ScheduleEntryView(entry: entry)
        }
        .supportedFamilies(supportedWidgetFamilies)
        .configurationDisplayName("Splatoon 3")
        .description("Splatoon 3 Schedules")
    }
}

struct Schedule_Previews: PreviewProvider {
    
    static let schedule = Splatoon2Schedule.example
    
    static var regularEvents : [Splatoon2.GameModeEvent] {
        return schedule.gameModes.regular.schedule
    }

    static var rankedEvents : [Splatoon2.GameModeEvent] {
        return schedule.gameModes.ranked.schedule
    }

    static var leagueEvents : [Splatoon2.GameModeEvent] {
        return schedule.gameModes.league.schedule
    }

    static var intent : ConfigurationIntent {
        return ConfigurationIntent()
    }

    static var intentWithDisplayNext : ConfigurationIntent {
        let intent = ConfigurationIntent()
        intent.displayNext = true
        return intent
    }
    

    static var previews: some View {

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.gameModes.regular.schedule), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

//        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.detailedEvents, timeframes: schedule.coop.eventTimeframes), configuration: ConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemLarge))

        //        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.detailedEvents, timeframes: schedule.coop.eventTimeframes), configuration: ConfigurationIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemExtraLarge))

    }
}
