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
    
    let scheduleFetcher = ScheduleFetcher()
    static let schedule = Splatoon2Schedule.example
    let imageLoaderManager = ImageLoaderManager()
    
    static var regularEvents : [Splatoon2.GameModeEvent] {
        return schedule.gameModes.regular.schedule
    }
    static var coopEvents : [CoopEvent] {
        return schedule.coop.detailedEvents
    }

    func placeholder(in context: Context) -> GameModeEntry {
        GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon2TimelineProvider.regularEvents), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (GameModeEntry) -> ()) {
        print("Display Snapshot isPreview:\(context.isPreview)")
        scheduleFetcher.useSharedFolderForCaching = true
        switch configuration.scheduleType {
        case .regular, .ranked, .league:
            scheduleFetcher.fetchGameModeTimelines { (timelines, error) in
                guard let timelines = timelines else {
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon2TimelineProvider.regularEvents), configuration: configuration)
                    completion(entry)
                    return
                }
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: timelines.regular.schedule), configuration: configuration)
                completion(entry)
            }
        case .salmonRun:
            scheduleFetcher.fetchCoopTimeline { timeline, error in
                guard let timeline = timeline else {
                    let entry = GameModeEntry(date: Date(), events: .coopEvents(events: Splatoon2TimelineProvider.coopEvents, timeframes: []), configuration: configuration)
                    completion(entry)
                    return
                }
                let entry = GameModeEntry(date: Date(), events: .coopEvents(events: timeline.detailedEvents, timeframes: timeline.eventTimeframes), configuration: configuration)
                completion(entry)
            }
        case .unknown:
            break
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<GameModeEntry>) -> ()) {
        let mode = configuration.scheduleType
        scheduleFetcher.useSharedFolderForCaching = true

        print("TimelineProvider getTimeline \(self)")

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

                let selectedTimeline : Splatoon2.GameModeTimeline
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
    
    func timelineForGameModeTimeline(_ modeTimeline: Splatoon2.GameModeTimeline, for configuration: ConfigurationIntent) -> Timeline<GameModeEntry> {
        var entries: [GameModeEntry] = []
        let now = Date()
        let startDates = modeTimeline.schedule.map({ $0.timeframe.startDate })
        print("StartDates: \(startDates)")
        let dates = ([now]+startDates).sorted()
        for date in dates {
            let events = modeTimeline.upcomingEventsAfterDate(date: date)
            if events.count > 1 {
                let entry = GameModeEntry(date: date, events: .gameModeEvents(events: events), configuration: configuration)
                entries.append(entry)
            }
        }
        var updatePolicy: TimelineReloadPolicy = .atEnd
        if let date = startDates.suffix(2).first, date > Date() {
            print("Refresh at: \(date)")
            updatePolicy = .after(date)
        }
        let timeline = Timeline(entries: entries, policy: updatePolicy)
        return timeline
    }
    
    func timelineForCoopTimeline(_ coopTimeline: CoopTimeline, for configuration: ConfigurationIntent) -> Timeline<GameModeEntry> {
        if configuration.isDisplayNext, let firstEvent = coopTimeline.firstEvent, let secondEvent = coopTimeline.secondEvent {
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
        var dates: [Date] = []
        let now = Date()
        var updatePolicy: TimelineReloadPolicy = .atEnd
        if let timeframe = coopTimeline.firstEvent?.timeframe {
            if now < timeframe.startDate {
                dates.append(now)
            }
            dates.append(timeframe.startDate)
            dates.append(timeframe.endDate)
            updatePolicy = .after(timeframe.endDate)
        }else{
            dates.append(now)
        }

        
        //let dates = coopTimeline.eventChangingDates()
        print("Dates: \(dates)")
        for date in dates {
            let events = coopTimeline.upcomingEventsAfterDate(date: date)
            let eventTimeframes = coopTimeline.upcomingTimeframesAfterDate(date: date)
//            if events.count > 1 {
                let entry = GameModeEntry(date: date, events: .coopEvents(events: events, timeframes: eventTimeframes), configuration: configuration)
                entries.append(entry)
//            }
        }
//        if let date = dates.suffix(2).first, date > Date() {
//            print("Refresh at: \(date)")
//            updatePolicy = .after(date)
//        }
        for entry in entries {
            print("#########")
            print("Date: \(entry.date)")
            switch entry.events {
            case .gameModeEvents(events: let events):
                for event in events {
                    print("\(event.mode.name) from \(event.timeframe.startDate) until \(event.timeframe.endDate)")
                }
                break
            case .coopEvents(events: let events, timeframes: let timeframes):
                for event in events {
                    print("\(event.stage.name) from \(event.timeframe.startDate) until \(event.timeframe.endDate)")
                }
                break
            }
            print("#########")
        }
        let timeline = Timeline(entries: entries, policy: updatePolicy)
        return timeline
    }
}
