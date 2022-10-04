//
//  Splatoon2TimelineProvider.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 19.09.22.
//

import WidgetKit
import SwiftUI
import Intents

struct Splatoon2TimelineProvider: IntentTimelineProvider {
    
    enum TimelineType {
        case game(timeline: GameTimeline)
        case coop(timeline: CoopTimeline)
    }

    let scheduleFetcher = ScheduleFetcher()
    let imageLoaderManager = ImageLoaderManager()
    
    static var exampleSchedule: Splatoon2.Schedule {
        // if available, use cached schedule
        guard let cache = ScheduleFetcher.loadCachedSplatoon2Schedule() else { return Splatoon2.Schedule.empty }
        return cache.schedule
    }
    
    static var exampleGameEvents : [GameModeEvent] {
        return Splatoon2TimelineProvider.exampleSchedule.regular.events
    }
    static var exampleCoopEvents : [CoopEvent] {
        return Splatoon2TimelineProvider.exampleSchedule.coop.events
    }
    

    // MARK: -

    func downloadImages(urls: [URL], asJPEG: Bool = true, completion: @escaping ()->Void) {
        let destination = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName) ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let multiImageLoader = MultiImageLoader(urls: urls, directory: destination)
        multiImageLoader.storeAsJPEG = asJPEG
        imageLoaderManager.imageLoaders.append(multiImageLoader)
        multiImageLoader.load {
            completion()
        }
    }
    
    // MARK: -

    func placeholder(in context: Context) -> GameModeEntry {
        return GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon2TimelineProvider.exampleGameEvents), configuration: Splatoon2_ScheduleIntent())
    }

    func getSnapshot(for configuration: Splatoon2_ScheduleIntent, in context: Context, completion: @escaping (GameModeEntry) -> ()) {
        if context.isPreview {
            let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon2TimelineProvider.exampleGameEvents), configuration: Splatoon2_ScheduleIntent())
            completion(entry)
            return
        }
        ScheduleFetcher.useSharedFolderForCaching = true

        scheduleFetcher.fetchSplatoon2Schedule(completion: { result in
            switch result {
            case .success(let schedule):
                
                switch configuration.scheduleType {
                case .regular:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.regular.events), configuration: configuration)
                    completion(entry)
                case .ranked:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.ranked.events), configuration: configuration)
                    completion(entry)
                case .league:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.league.events), configuration: configuration)
                    completion(entry)
                case .unknown:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.regular.events), configuration: configuration)
                    completion(entry)
                    break
                case .salmonRun:
                    let entry = GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.events, timeframes: schedule.coop.otherTimeframes), configuration: configuration)
                    completion(entry)
                    break
                }
            case .failure(_):
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon2TimelineProvider.exampleGameEvents), configuration: configuration)
                completion(entry)
                break
            }
        })
    }
    
    func getTimeline(for configuration: Splatoon2_ScheduleIntent, in context: Context, completion: @escaping (Timeline<GameModeEntry>) -> ()) {
        let mode = configuration.scheduleType
        ScheduleFetcher.useSharedFolderForCaching = true

        scheduleFetcher.fetchSplatoon2Schedule { result in
            switch result {
            case .success(let schedule):

                let selectedTimeline: TimelineType
                let urls: [URL]
                switch mode {
                case .regular:
                    urls = schedule.regular.allImageURLs()
                    selectedTimeline = .game(timeline: schedule.regular)
                case .ranked:
                    urls = schedule.ranked.allImageURLs()
                    selectedTimeline = .game(timeline: schedule.ranked)
                case .league:
                    urls = schedule.league.allImageURLs()
                    selectedTimeline = .game(timeline: schedule.league)
                case .salmonRun:
                    urls = schedule.coop.allImageURLs()
                    selectedTimeline = .coop(timeline: schedule.coop)
                default:
                    let entries: [GameModeEntry] = []
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                    return
                }
                downloadImages(urls: urls, asJPEG: true) {
                    switch selectedTimeline {
                    case .game(let timeline):
                        let timeline = timelineForGameModeTimeline(timeline, for: configuration)
                        completion(timeline)
                    case .coop(let timeline):
                        downloadImages(urls: schedule.coop.allWeaponImageURLs(), asJPEG: false) {
                            let timeline = timelineForCoopTimeline(timeline, for: configuration)
                            completion(timeline)
                        }
                    }
                }
                return

            case .failure(_):
                let entries: [GameModeEntry] = []
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
    }
    
    @available(iOSApplicationExtension 16.0, *)
    func recommendations() -> [IntentRecommendation<Splatoon2_ScheduleIntent>] {
        return []
    }

    func timelineForGameModeTimeline(_ modeTimeline: GameTimeline, for configuration: Splatoon2_ScheduleIntent) -> Timeline<GameModeEntry> {
        let now = Date()
        var entries: [GameModeEntry] = []
//        let startDates = modeTimeline.events.map({ $0.timeframe.startDate })
//        print("StartDates: \(startDates)")
//        let dates = ([now]+startDates).sorted()
//        for date in dates {
//            let events = modeTimeline.events.upcomingEventsAfterDate(date: date)
//            if events.count > 1 {
//                let entry = GameModeEntry(date: date, events: .gameModeEvents(events: events), configuration: configuration)
//                entries.append(entry)
//            }
//        }
//        var updatePolicy: TimelineReloadPolicy = .atEnd
//        if let date = startDates.suffix(2).first, date > Date() {
//            print("Refresh at: \(date)")
//            updatePolicy = .after(date)
//        }
        let eventTimelineResult = modeTimeline.eventTimeline(startDate: now)
        for gameEvent in eventTimelineResult.events {
            let entry = GameModeEntry(date: gameEvent.date, events: .gameModeEvents(events: gameEvent.events), configuration: configuration)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: eventTimelineResult.updatePolicy)
        return timeline
    }
    
    func timelineForCoopTimeline(_ coopTimeline: CoopTimeline, for configuration: Splatoon2_ScheduleIntent) -> Timeline<GameModeEntry> {
        if configuration.isDisplayNext, let firstEvent = coopTimeline.events.first, let secondEvent = coopTimeline.events.second {
            // only show next event
            let entry = GameModeEntry(date: Date(), events: .coopEvents(events: [secondEvent], timeframes: []), configuration: configuration)
            let timeline = Timeline(entries: [entry], policy: .after(firstEvent.timeframe.endDate))
            return timeline
        }
        var entries: [GameModeEntry] = []
        // coopTimeline consists of 2 detailed events and some additional timeframes for other events.
        // The widget has to show the first 2 events full
        // Therefore, the widget timeline consists of only a few dates
        // Current date: Event 1 (active/soon), Event 2 soon
        // Event 1 start date: Event 1 active, Event 2 soon
        // Event 1 end date: Event 2 soon, nothing  <-- NOT GOOD
        // Therefore, the timeline only consists of 2 timeline entries:
        // 1: Current Date
        // 2: Event 1 Start Date
        // Refresh happens at Event 1 End Date
        // When the widget refreshes at the end of Event 1, the new coopTimeline will have 2 new events
        let now = Date()
        let eventTimelineResult = coopTimeline.eventTimeline(startDate: now, numberOfRemainingEventsBeforeUpdate: 2)

//        var dates: [Date] = []
//        var updatePolicy: TimelineReloadPolicy = .atEnd
//        if let timeframe = coopTimeline.events.first?.timeframe {
//            if now < timeframe.startDate {
//                dates.append(now)
//            }
//            dates.append(timeframe.startDate)
//            dates.append(timeframe.endDate)
//            updatePolicy = .after(timeframe.endDate)
//        }else{
//            dates.append(now)
//        }

        
        //let dates = coopTimeline.eventChangingDates()
//        print("Dates: \(dates)")
//        for date in dates {
//            let events = coopTimeline.upcomingEventsAfterDate(date: date)
//            let eventTimeframes = coopTimeline.otherTimeframes.upcomingTimeframesAfterDate(date: date)
////            if events.count > 1 {
//                let entry = GameModeEntry(date: date, events: .coopEvents(events: events, timeframes: eventTimeframes), configuration: configuration)
//                entries.append(entry)
////            }
//        }
        
//        if let date = dates.suffix(2).first, date > Date() {
//            print("Refresh at: \(date)")
//            updatePolicy = .after(date)
//        }
//        for entry in entries {
//            print("#########")
//            print("Date: \(entry.date)")
//            switch entry.events {
//            case .gameModeEvents(events: let events):
//                for event in events {
//                    print("\(event.mode.name) from \(event.timeframe.startDate) until \(event.timeframe.endDate)")
//                }
//                break
//            case .coopEvents(events: let events, timeframes: _):
//                for event in events {
//                    print("\(event.stage.name) from \(event.timeframe.startDate) until \(event.timeframe.endDate)")
//                }
//                break
//            }
//            print("#########")
//        }
        for gameEvent in eventTimelineResult.events {
            let entry = GameModeEntry(date: gameEvent.date, events: .coopEvents(events: gameEvent.events, timeframes: []), configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: eventTimelineResult.updatePolicy)
        return timeline
    }
    
    
    struct GameModeEntry: TimelineEntry {
        let date: Date
        let events: GameModeEvents
        let configuration: Splatoon2_ScheduleIntent
    }

    enum GameModeEvents {
        case gameModeEvents(events: [GameModeEvent])
        case coopEvents(events: [CoopEvent], timeframes: [EventTimeframe])
    }


    struct ScheduleEntryView : View {
        var entry: Splatoon2TimelineProvider.Entry
        
        var gameModeType : GameModeType {
            switch entry.configuration.scheduleType {
            case .unknown, .salmonRun, .regular:
                return .splatoon2(type: .turfWar)
            case .ranked:
                return .splatoon2(type: .ranked)
            case .league:
                return .splatoon2(type: .league)
            }
        }
        
        var body: some View {
            Group {
                switch entry.events {
                case .gameModeEvents(_):
                    GameModeEntryView(gameMode: gameModeType, events: gameModeEvents, date: entry.date).foregroundColor(.white).environmentObject(imageQuality)
                case .coopEvents(events: _, timeframes: let timeframes):
                    CoopEntryView(events: coopEvents, eventTimeframes: timeframes, date: entry.date).foregroundColor(.white).environmentObject(imageQuality)
                }
            }
        }
        
        var imageQuality : ImageQuality = {
            let quality = ImageQuality()
            quality.thumbnail = true
            return quality
        }()
        
        
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
}

extension Splatoon2_ScheduleIntent {
    
    var isDisplayNext: Bool {
        guard let next = self.displayNext else { return false }
        return next.boolValue
    }
}
