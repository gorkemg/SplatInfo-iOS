//
//  Splatoon3TimelineProvider.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 19.09.22.
//

import WidgetKit
import SwiftUI
import Intents

struct Splatoon3TimelineProvider: IntentTimelineProvider {
        
    enum TimelineType {
        case game(timeline: GameTimeline)
        case coop(timeline: CoopTimeline)
    }

    let scheduleFetcher = ScheduleFetcher()
    let imageLoaderManager = ImageLoaderManager()
    
    static var exampleSchedule: Splatoon3.Schedule {
        // if available, use cached schedule
        guard let cache = ScheduleFetcher.loadCachedSplatoon3Schedule() else { return Splatoon3.Schedule.example }
        return cache.schedule
    }
    
    static var exampleGameEvents : [GameModeEvent] {
        return Splatoon3TimelineProvider.exampleSchedule.regular.events
    }
    static var exampleCoopEvents : [CoopEvent] {
        return Splatoon3TimelineProvider.exampleSchedule.coop.events
    }

    func placeholder(in context: Context) -> GameModeEntry {
        return GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon3TimelineProvider.exampleGameEvents), configuration: Splatoon3_ScheduleIntent())
    }

    func getSnapshot(for configuration: Splatoon3_ScheduleIntent, in context: Context, completion: @escaping (GameModeEntry) -> ()) {
        if context.isPreview {
            let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon3TimelineProvider.exampleGameEvents), configuration: Splatoon3_ScheduleIntent())
            completion(entry)
            return
        }
        ScheduleFetcher.useSharedFolderForCaching = true

        scheduleFetcher.fetchSplatoon3Schedule(completion: { result in
            switch result {
            case .success(let schedule):
                
                switch configuration.scheduleType {
                case .turfWar, .unknown:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.regular.events), configuration: configuration)
                    completion(entry)
                case .anarchyOpen:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.anarchyBattleOpen.events), configuration: configuration)
                    completion(entry)
                case .anarchySeries:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.anarchyBattleSeries.events), configuration: configuration)
                    completion(entry)
                case .league:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.league.events), configuration: configuration)
                    completion(entry)
                case .x:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.x.events), configuration: configuration)
                    completion(entry)
                case .salmonRun:
                    let entry = GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.events, timeframes: schedule.coop.otherTimeframes), configuration: configuration)
                    completion(entry)
                }
            case .failure(_):
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon3TimelineProvider.exampleGameEvents), configuration: configuration)
                completion(entry)
                break
            }
        })
    }
    
    func getTimeline(for configuration: Splatoon3_ScheduleIntent, in context: Context, completion: @escaping (Timeline<GameModeEntry>) -> ()) {
        let mode = configuration.scheduleType
        ScheduleFetcher.useSharedFolderForCaching = true

        scheduleFetcher.fetchSplatoon3Schedule { result in
            switch result {
            case .success(let schedule):

                let selectedTimeline: TimelineType
                let urls: [URL]
                switch mode {
                case .turfWar, .unknown:
                    urls = schedule.regular.allImageURLs()
                    selectedTimeline = .game(timeline: schedule.regular)
                case .anarchyOpen:
                    urls = schedule.anarchyBattleOpen.allImageURLs()
                    selectedTimeline = .game(timeline: schedule.anarchyBattleOpen)
                case .anarchySeries:
                    urls = schedule.anarchyBattleSeries.allImageURLs()
                    selectedTimeline = .game(timeline: schedule.anarchyBattleSeries)
                case .league:
                    urls = schedule.league.allImageURLs()
                    selectedTimeline = .game(timeline: schedule.league)
                case .x:
                    urls = schedule.x.allImageURLs()
                    selectedTimeline = .game(timeline: schedule.x)
                case .salmonRun:
                    urls = schedule.coop.allImageURLs()
                    selectedTimeline = .coop(timeline: schedule.coop)
                }
                let destination = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName) ?? URL(fileURLWithPath: NSTemporaryDirectory())
                let multiImageLoader = MultiImageLoader(urls: urls, directory: destination)
                imageLoaderManager.imageLoaders.append(multiImageLoader)
                multiImageLoader.load {
                    switch selectedTimeline {
                    case .game(let timeline):
                        let timeline = timelineForGameModeTimeline(timeline, for: configuration)
                        completion(timeline)
                    case .coop(let timeline):
                        let timeline = timelineForCoopTimeline(timeline, for: configuration)
                        completion(timeline)
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
    func recommendations() -> [IntentRecommendation<Splatoon3_ScheduleIntent>] {
        return []
    }

    func timelineForGameModeTimeline(_ modeTimeline: GameTimeline, for configuration: Splatoon3_ScheduleIntent) -> Timeline<GameModeEntry> {
        let now = Date()
        var entries: [GameModeEntry] = []
        let eventTimelineResult = modeTimeline.eventTimeline(startDate: now)
        for gameEvent in eventTimelineResult.events {
            let entry = GameModeEntry(date: gameEvent.date, events: .gameModeEvents(events: gameEvent.events), configuration: configuration)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: eventTimelineResult.updatePolicy)
        return timeline
    }    
    
    func timelineForCoopTimeline(_ coopTimeline: CoopTimeline, for configuration: Splatoon3_ScheduleIntent) -> Timeline<GameModeEntry> {
        var entries: [GameModeEntry] = []
        let now = Date()
        let eventTimelineResult = coopTimeline.eventTimeline(startDate: now, numberOfRemainingEventsBeforeUpdate: 2)
        for gameEvent in eventTimelineResult.events {
            let entry = GameModeEntry(date: gameEvent.date, events: .coopEvents(events: gameEvent.events, timeframes: []), configuration: configuration)
            entries.append(entry)
        }
        let timeline = Timeline(entries: entries, policy: eventTimelineResult.updatePolicy)
        return timeline
    }
    
    
    struct GameModeEntry: TimelineEntry {
        let date: Date                                  // widget update date
        let events: GameModeEvents
        let configuration: Splatoon3_ScheduleIntent
    }

    enum GameModeEvents {
        case gameModeEvents(events: [GameModeEvent])
        case coopEvents(events: [CoopEvent], timeframes: [EventTimeframe])
    }


    struct ScheduleEntryView : View {
        var entry: Splatoon3TimelineProvider.Entry
        
        var gameModeType : GameModeType {
            switch entry.configuration.scheduleType {
            case .unknown, .turfWar:
                return .splatoon3(type: .turfWar)
            case .anarchyOpen:
                return .splatoon3(type: .anarchyBattleOpen)
            case .anarchySeries:
                return .splatoon3(type: .anarchyBattleSeries)
            case .league:
                return .splatoon3(type: .league)
            case .x:
                return .splatoon3(type: .x)
            case .salmonRun:
                return .splatoon3(type: .salmonRun)
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

extension Splatoon3_ScheduleIntent {
    
    var isDisplayNext: Bool {
        guard let next = self.displayNext else { return false }
        return next.boolValue
    }
}
