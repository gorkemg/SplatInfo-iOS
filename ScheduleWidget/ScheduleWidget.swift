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
                    let timeline = Timeline(entries: entries, policy: .atEnd)
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
                        let timeline = Timeline(entries: entries, policy: .atEnd)
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
                    let timeline = Timeline(entries: entries, policy: .atEnd)
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
        var entries: [GameModeEntry] = []
        let now = Date()
        let startDates = modeTimeline.schedule.map({ $0.timeframe.startDate })
        let dates = ([now]+startDates).sorted()
        for date in dates {
            let events = modeTimeline.upcomingEventsAfterDate(date: date)
            if events.count > 1 {
                let entry = GameModeEntry(date: date, events: .gameModeEvents(events: events), configuration: configuration)
                entries.append(entry)
            }
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        return timeline
    }
    
    func timelineForCoopTimeline(_ coopTimeline: CoopTimeline, for configuration: ConfigurationIntent) -> Timeline<GameModeEntry> {
        var entries: [GameModeEntry] = []
        let dates = coopTimeline.eventChangingDates()
        for date in dates {
            let events = coopTimeline.upcomingEventsAfterDate(date: date)
            let eventTimeframes = coopTimeline.upcomingTimeframesAfterDate(date: date)
            let entry = GameModeEntry(date: date, events: .coopEvents(events: events, timeframes: eventTimeframes), configuration: configuration)
            entries.append(entry)
        }
        var updatePolicy: TimelineReloadPolicy = .atEnd
        if let date = coopTimeline.firstEvent?.timeframe.endDate, date > Date() {
            updatePolicy = .after(date)
        }
        let timeline = Timeline(entries: entries, policy: updatePolicy)
        return timeline
    }
}

extension ConfigurationIntent {
    
    var isDisplayNext: Bool {
        guard let next = self.displayNext else { return false }
        return next.boolValue
    }
    
}

extension CoopTimeline {
    
    var firstEvent: CoopEvent? {
        return detailedEvents.first
    }

    var secondEvent: CoopEvent? {
        if detailedEvents.count > 1 {
            return detailedEvents[1]
        }
        return nil
    }

    
    func eventChangingDates() -> [Date] {
        let now = Date()
        let startDates = detailedEvents.map({ $0.timeframe.startDate })
        let endDates = detailedEvents.map({ $0.timeframe.endDate })
        var eventDates = (startDates+endDates).sorted()
        if let firstDate = eventDates.first, now < firstDate {
            eventDates.insert(now, at: 0)
        }
        return eventDates
    }
    
    func upcomingEventsAfterDate(date: Date) -> [CoopEvent] {
        return detailedEvents.filter({ $0.timeframe.state(date: date) != .over })
    }

    func upcomingTimeframesAfterDate(date: Date) -> [EventTimeframe] {
        return eventTimeframes.filter({ $0.state(date: date) != .over })
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
        case .gameModeEvents(events: _):
            GameModeEntryView(gameMode: gameModeType, events: gameModeEvents, date: entry.date)
        case .coopEvents(events: _, timeframes: let timeframes):
            CoopEntryView(events: coopEvents, eventTimeframes: timeframes, date: entry.date)
        }
    }
    
    var displayNext: Bool {
        guard let displayNext = entry.configuration.displayNext else { return false }
        return displayNext.boolValue
    }

    var gameModeEvents: [GameModeEvent] {
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
    let gameMode: GameModeType
    let events: [GameModeEvent]
    let date: Date
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    var body: some View {
        ZStack {
            Image("bg-squids").resizable(resizingMode: .tile).ignoresSafeArea()
            
            if let event = event {
                switch widgetFamily {
                case .systemSmall:
                    SmallGameModeWidgetView(event: event, nextEvent: nextEvent, date: date)
                case .systemMedium:
                    LargerGameModeWidgetView(event: event, nextEvent: nextEvent, date: date)
                case .systemLarge:
                    LargerGameModeWidgetView(event: event, nextEvent: nextEvent, date: date)
                @unknown default:
                    Text("No event available").splat1Font(size: 20)
                }
            }else{
                Text("No event available").splat1Font(size: 20)
            }
        }.foregroundColor(.white)
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
            LargerCoopWidgetView(events: events, eventTimeframes: otherTimeframes, date: date, style: .narrow)
        case .systemLarge:
            LargerCoopWidgetView(events: events, eventTimeframes: otherTimeframes, date: date, style: .large)
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
