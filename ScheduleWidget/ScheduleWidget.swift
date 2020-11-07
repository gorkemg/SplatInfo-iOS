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
    
    let scheduleFetcher = ScheduleFetcher()
    static let schedule = Schedule.example
    let imageLoaderManager = ImageLoaderManager()

    static var regularEvents : [GameModeEvent] {
        return schedule.gameModes.regular.schedule
    }

    func placeholder(in context: Context) -> GameModeEntry {
        GameModeEntry(date: Date(), events: .gameModeEvents(events: Provider.regularEvents), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (GameModeEntry) -> ()) {
        scheduleFetcher.useSharedFolderForCaching = true
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
        scheduleFetcher.useSharedFolderForCaching = true

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
                let destination = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName) ?? URL(fileURLWithPath: NSTemporaryDirectory())
                let multiImageLoader = MultiImageLoader(urls: selectedTimeline.allImageURLs(), directory: destination)
                imageLoaderManager.imageLoaders.append(multiImageLoader)
                multiImageLoader.load {
                    let timeline = timelineForGameModeTimeline(selectedTimeline, for: configuration)
                    completion(timeline)
                }
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
                let destination = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName) ?? URL(fileURLWithPath: NSTemporaryDirectory())
                let multiImageLoader = MultiImageLoader(urls: coopTimeline.allStageImageURLs(), directory: destination)
                multiImageLoader.storeAsJPEG = true
                imageLoaderManager.imageLoaders.append(multiImageLoader)
                multiImageLoader.load {
                    let multiImageLoader = MultiImageLoader(urls: coopTimeline.allWeaponImageURLs(), directory: destination)
                    multiImageLoader.storeAsJPEG = false
                    imageLoaderManager.imageLoaders.append(multiImageLoader)
                    multiImageLoader.load {
                        let timeline = timelineForCoopTimeline(coopTimeline, for: configuration)
                        completion(timeline)
                    }
                }
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
        let endDates = coopTimeline.detailedEvents.map({ $0.timeframe.endDate })
        let dates = (startDates+endDates).sorted()
        for date in dates {
            let events = coopTimeline.detailedEvents.filter({ $0.timeframe.startDate >= date })
            if events.count > 0 {
                let eventTimeframes = coopTimeline.eventTimeframes.filter({ $0.startDate >= date })
                let entry = GameModeEntry(date: date, events: .coopEvents(events: events, timeframes: eventTimeframes), configuration: configuration)
                entries.append(entry)
            }
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
        ZStack {
            Image("bg-squids").resizable(resizingMode: .tile).ignoresSafeArea()
            
            if let event = event {
                switch widgetFamily {
                case .systemSmall:
                    SmallGameModeWidgetView(event: event, nextEvent: nextEvent)
                case .systemMedium:
                    LargerGameModeWidgetView(event: event, nextEvent: nextEvent)
                case .systemLarge:
                    LargerGameModeWidgetView(event: event, nextEvent: nextEvent)
                @unknown default:
                    Text("No event available").splat1Font(size: 20)
                }
            }else{
                Text("No event available").splat1Font(size: 20)
            }
        }.foregroundColor(.white)
    }
    
    var event: GameModeEvent? {
        if displayNext, events.count > 1 {
            return events[1]
        }
        return events.first
    }
    var nextEvent: GameModeEvent? {
        if let currentEvent = self.event, let index = events.firstIndex(where: { $0 == currentEvent }), events.count > index+1 {
            return events[(index+1)]
        }
        return nil
    }
}


struct CoopEntryView : View {
    let events: [CoopEvent]
    let eventTimeframes: [EventTimeframe]
    let displayNext: Bool

    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            if let event = event {
                SmallCoopWidgetView(event: event)
            }else{
                Text("No event available")
            }
        case .systemMedium:
            LargerCoopWidgetView(events: events, eventTimeframes: otherTimeframes, style: .narrow)
        case .systemLarge:
            LargerCoopWidgetView(events: events, eventTimeframes: otherTimeframes, style: .large)
        @unknown default:
            if let event = event {
                SmallCoopWidgetView(event: event)
            }else{
                Text("No event available")
            }
        }
    }

    var event: CoopEvent? {
        if displayNext, events.count > 1 {
            return events[1]
        }
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

    static var intent : ConfigurationIntent {
        return ConfigurationIntent()
    }

    static var intentWithDisplayNext : ConfigurationIntent {
        let intent = ConfigurationIntent()
        intent.displayNext = true
        return intent
    }
    

    static var previews: some View {
        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: []), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: regularEvents), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: rankedEvents), configuration: intent))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: rankedEvents), configuration: intentWithDisplayNext))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: leagueEvents), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.detailedEvents, timeframes: schedule.coop.eventTimeframes), configuration: intent))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.detailedEvents, timeframes: schedule.coop.eventTimeframes), configuration: intent))
            .previewContext(WidgetPreviewContext(family: .systemLarge))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: regularEvents), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
