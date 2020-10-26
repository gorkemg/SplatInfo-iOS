//
//  Schedule.swift
//  Schedule
//
//  Created by Görkem Güclü on 23.10.20.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    
    static let schedule = Schedule.example
    
    static var regularEvents : [GameModeEvent] {
        return schedule.gameModes.regular.schedule
    }

    func placeholder(in context: Context) -> GameModeEntry {
        GameModeEntry(date: Date(), events: .gameModeEvents(events: Provider.regularEvents), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (GameModeEntry) -> ()) {
        let scheduleFetcher = ScheduleFetcher()
        scheduleFetcher.fetchGameModeTimelines { (timelines, error) in
            guard let timelines = timelines else {
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Provider.regularEvents), configuration: configuration)
                completion(entry)
                return
            }
            let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: timelines.regular.schedule), configuration: configuration)
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let mode = configuration.scheduleType
        let scheduleFetcher = ScheduleFetcher()
        
        // load data according to mode
        switch mode {
        
        case .regular, .ranked, .league:
            
            scheduleFetcher.fetchGameModeTimelines { (timelines, error) in
                guard let timelines = timelines else {
                    let entries: [GameModeEntry] = []
                    let timeline = Timeline(entries: entries, policy: .after(Date().addingTimeInterval(60)))
                    completion(timeline)
                    return
                }
                let selectedTimeline : GameModeTimeline
                switch mode {
                    case .regular:
                        selectedTimeline = timelines.regular
                    case .ranked:
                        selectedTimeline = timelines.ranked
                    case .league:
                        selectedTimeline = timelines.league
                    default:
                        let entries: [GameModeEntry] = []
                        let timeline = Timeline(entries: entries, policy:  .after(Date().addingTimeInterval(60)))
                        completion(timeline)
                        return
                }
                let timeline = timelineForGameModeTimeline(selectedTimeline, for: configuration)
                completion(timeline)
                return
            }
            break
            
        case .salmonRun:
            
            scheduleFetcher.fetchCoopTimeline { (coopTimeline, error) in
                guard let coopTimeline = coopTimeline else {
                    let entries: [GameModeEntry] = []
                    let timeline = Timeline(entries: entries, policy:  .after(Date().addingTimeInterval(60)))
                    completion(timeline)
                    return
                }
                let timeline = timelineForCoopTimeline(coopTimeline, for: configuration)
                completion(timeline)
                return
            }
            break
            
        default:
            let entries: [GameModeEntry] = []
            let timeline = Timeline(entries: entries, policy: .after(Date().addingTimeInterval(60)))
            completion(timeline)
            break
        }
    }
    
    func timelineForGameModeTimeline(_ modeTimeline: GameModeTimeline, for configuration: ConfigurationIntent) -> Timeline<GameModeEntry> {
        let oneHour = Date(timeIntervalSinceNow: 3600)
        var entries: [GameModeEntry] = []
        let startDates = modeTimeline.schedule.map({ $0.timeframe.startDate })
        for startDate in startDates {
            let events = modeTimeline.upcomingEventsAfterDate(date: startDate)
            let entry = GameModeEntry(date: startDate, events: .gameModeEvents(events: events), configuration: configuration)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .after(oneHour))
        return timeline
    }
    
    func timelineForCoopTimeline(_ coopTimeline: CoopTimeline, for configuration: ConfigurationIntent) -> Timeline<GameModeEntry> {
        let oneHour = Date(timeIntervalSinceNow: 3600)
        var entries: [GameModeEntry] = []
        let startDates = coopTimeline.detailedEvents.map({ $0.timeframe.startDate })
        for startDate in startDates {
            let events = coopTimeline.detailedEvents.filter({ $0.timeframe.startDate >= startDate })
            let eventTimeframes = coopTimeline.eventTimeframes.filter({ $0.startDate >= startDate })
            let entry = GameModeEntry(date: startDate, events: .coopEvents(events: events, timeframes: eventTimeframes), configuration: configuration)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: .after(oneHour))
        return timeline
    }
}

struct GameModeEntry: TimelineEntry {
    let date: Date
    let events: GameModeEvents
    let configuration: ConfigurationIntent
}

enum GameModeEvents {
    case gameModeEvents(events: [GameModeEvent])
    case coopEvents(events: [CoopEvent], timeframes: [EventTimeframe])
}


struct ScheduleEntryView : View {
    var entry: Provider.Entry
    
    var gameModeType : GameModeType {
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
        case .gameModeEvents(events: let events):
            GameModeEntryView(gameMode: gameModeType, events: events, displayNext: displayNext)
        case .coopEvents(events: let events, timeframes: let timeframes):
            CoopEntryView(events: events, eventTimeframes: timeframes, displayNext: displayNext)
        }
    }
    
    var displayNext: Bool {
        guard let displayNext = entry.configuration.displayNext else { return false }
        return displayNext.boolValue
    }
    
}

struct GameModeEntryView : View {
    let gameMode: GameModeType
    let events: [GameModeEvent]
    let displayNext: Bool
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    var body: some View {
        if let event = event {
            switch widgetFamily {
            case .systemSmall:
                SmallWidgetView(stages: event.stages, timeframe: event.timeframe, title: event.rule.name, modeLogo: event.mode.type.logoName, backgroundColor: event.mode.type.color)
            case .systemMedium:
                SmallWidgetView(stages: event.stages, timeframe: event.timeframe, title: event.rule.name, modeLogo: event.mode.type.logoName, backgroundColor: event.mode.type.color)
            case .systemLarge:
                SmallWidgetView(stages: event.stages, timeframe: event.timeframe, title: event.rule.name, modeLogo: event.mode.type.logoName, backgroundColor: event.mode.type.color)
            @unknown default:
                Text("No event available")
            }
        }else{
            Text("No event available")
        }
    }
    
    var event: GameModeEvent? {
        if displayNext, events.count > 1 {
            return events[1]
        }
        return events.first
    }
    
}

struct CoopEntryView : View {
    let events: [CoopEvent]
    let eventTimeframes: [EventTimeframe]
    let displayNext: Bool

    var body: some View {
        if let event = event {
            SmallWidgetView(stages: [event.stage], timeframe: event.timeframe, title: event.modeName, modeLogo: event.logoName, backgroundColor: event.color)
        }else{
            Text("No event available")
        }
    }

    var event: CoopEvent? {
        if displayNext, events.count > 1 {
            return events[1]
        }
        return events.first
    }
}

struct SmallWidgetView : View {
    let stages: [Stage]
    let timeframe: EventTimeframe
    let title: String
    let modeLogo: String
    var backgroundColor: Color? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {

            backgroundColor
            
            GeometryReader { geometry in
                VStack(spacing: 0.0) {
                    ForEach(stages, id: \.id) { stage in
                        Image("thumb_\(stage.id)").resizable().aspectRatio(contentMode: .fill).frame(width: geometry.size.width, height: geometry.size.height/2).clipped()
                    }
                }.cornerRadius(10.0)
            }
            
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.1), Color.black.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 0.0) {
                
                HStack {
                    Image(modeLogo).resizable().aspectRatio(contentMode: .fit).frame(width: 20)
                    Text(title).splat2Font(size: 14).minimumScaleFactor(0.5)
                }
                                
                Spacer()
                
                VStack(alignment: .leading) {
                    TimeframeView(timeframe: timeframe).lineLimit(2).minimumScaleFactor(0.5)
                }
            }.padding(.horizontal, 10.0)
        }.foregroundColor(.white)
    }
}


@main
struct ScheduleWidget: Widget {
    let kind: String = "ScheduleWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            ScheduleEntryView(entry: entry)
        }
        .configurationDisplayName("SplatInfo Widget")
        .description("Displays Splatoon 2 schedules")
    }
}

struct Schedule_Previews: PreviewProvider {
    
    static let schedule = Schedule.example
    
    static var regularEvents : [GameModeEvent] {
        return schedule.gameModes.regular.schedule
    }

    static var rankedEvents : [GameModeEvent] {
        return schedule.gameModes.ranked.schedule
    }

    static var leagueEvents : [GameModeEvent] {
        return schedule.gameModes.league.schedule
    }

    static var previews: some View {
        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: regularEvents), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: rankedEvents), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: leagueEvents), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.detailedEvents, timeframes: schedule.coop.eventTimeframes), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: regularEvents), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: regularEvents), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

extension GameModeType {
    
    var color : Color {
        switch self {
        case .regular:
            return Color("RegularModeColor")
        case .ranked:
            return Color("RankedModeColor")
        case .league:
            return Color("LeagueModeColor")
        }
    }
}

extension CoopEvent {
    var color : Color {
        return Color("CoopModeColor")
    }
}
