//
//  WatchScheduleWidgets.swift
//  WatchScheduleWidgets
//
//  Created by Görkem Güclü on 03.10.22.
//

import WidgetKit
import SwiftUI
import Intents

struct Splatoon3_WatchTimelineProvider: IntentTimelineProvider {

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
        return Splatoon3_WatchTimelineProvider.exampleSchedule.regular.events
    }
    static var exampleCoopEvents : [CoopEvent] {
        return Splatoon3_WatchTimelineProvider.exampleSchedule.coop.events
    }

    // MARK: -

    func placeholder(in context: Context) -> GameModeEntry {
        print("Placeholder Context: \(context)")
        return GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon3_WatchTimelineProvider.exampleGameEvents), configuration: Splatoon3_WatchScheduleIntent(), isPreview: true)
    }

    func getSnapshot(for configuration: Splatoon3_WatchScheduleIntent, in context: Context, completion: @escaping (GameModeEntry) -> ()) {
        if context.isPreview {
            switch configuration.scheduleType {
            case .turfWar, .unknown:
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon3_WatchTimelineProvider.exampleSchedule.regular.events), configuration: configuration, isPreview: true)
                completion(entry)
            case .anarchyOpen:
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon3_WatchTimelineProvider.exampleSchedule.anarchyBattleOpen.events), configuration: configuration, isPreview: true)
                completion(entry)
            case .anarchySeries:
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon3_WatchTimelineProvider.exampleSchedule.anarchyBattleSeries.events), configuration: configuration, isPreview: true)
                completion(entry)
            case .league:
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon3_WatchTimelineProvider.exampleSchedule.league.events), configuration: configuration, isPreview: true)
                completion(entry)
            case .x:
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon3_WatchTimelineProvider.exampleSchedule.x.events), configuration: configuration, isPreview: true)
                completion(entry)
            case .salmonRun:
                let entry = GameModeEntry(date: Date(), events: .coopEvents(events: Splatoon3_WatchTimelineProvider.exampleSchedule.coop.events, timeframes: Splatoon3_WatchTimelineProvider.exampleSchedule.coop.otherTimeframes), configuration: configuration, isPreview: true)
                completion(entry)
            }
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
                    downloadImages(urls: schedule.coop.allWeaponImageURLs(), resizeSize: .resizeToWidth(64.0)) {
                        let entry = GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.events, timeframes: schedule.coop.otherTimeframes), configuration: configuration)
                        completion(entry)
                    }
                }
            case .failure(_):
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon3_WatchTimelineProvider.exampleGameEvents), configuration: configuration)
                completion(entry)
                break
            }
        })
        
    }

    func getTimeline(for configuration: Splatoon3_WatchScheduleIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let mode = configuration.scheduleType
        ScheduleFetcher.useSharedFolderForCaching = true

        scheduleFetcher.fetchSplatoon3Schedule { result in
            switch result {
            case .success(let schedule):

                let selectedTimeline: TimelineType
                switch mode {
                case .turfWar, .unknown:
                    selectedTimeline = .game(timeline: schedule.regular)
                case .anarchyOpen:
                    selectedTimeline = .game(timeline: schedule.anarchyBattleOpen)
                case .anarchySeries:
                    selectedTimeline = .game(timeline: schedule.anarchyBattleSeries)
                case .league:
                    selectedTimeline = .game(timeline: schedule.league)
                case .x:
                    selectedTimeline = .game(timeline: schedule.x)
                case .salmonRun:
                    selectedTimeline = .coop(timeline: schedule.coop)
                }
                switch selectedTimeline {
                case .game(let timeline):
                    let timeline = timelineForGameModeTimeline(timeline, for: configuration)
                    completion(timeline)
                case .coop(let timeline):
                    downloadImages(urls: schedule.coop.allWeaponImageURLs(), asJPEG: false, resizeSize: .resizeToWidth(64.0)) {
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
    
    func recommendations() -> [IntentRecommendation<Splatoon3_WatchScheduleIntent>] {
        return [
            IntentRecommendation(intent: .turfWarConfig, description: "Splatoon 3 - Turf War"),
            IntentRecommendation(intent: .anarchyBattleOpenConfig, description: "Splatoon 3 - Anarchy Battle Open"),
            IntentRecommendation(intent: .anarchyBattleSeriesConfig, description: "Splatoon 3 - Anarchy Battle Series"),
//            IntentRecommendation(intent: .leagueConfig, description: "Splatoon 3 - League"),
//            IntentRecommendation(intent: .xConfig, description: "Splatoon 3 - X"),
            IntentRecommendation(intent: .salmonRunConfig, description: "Splatoon 3 - Salmon Run")
        ]
    }
    
    // MARK: -
    
    func downloadImages(urls: [URL], asJPEG: Bool = true, resizeSize: MultiImageLoader.ResizeOption? = nil, completion: @escaping ()->Void) {
        let destination = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName) ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let multiImageLoader = MultiImageLoader(urls: urls, directory: destination)
        multiImageLoader.storeAsJPEG = asJPEG
        multiImageLoader.resizeOption = resizeSize
        imageLoaderManager.imageLoaders.append(multiImageLoader)
        multiImageLoader.load {
            completion()
        }
    }

    
    // MARK: -
    
    struct GameModeEntry: TimelineEntry {
        let date: Date
        let events: GameModeEvents
        let configuration: Splatoon3_WatchScheduleIntent
        var isPreview: Bool = false
        
        enum GameModeEvents {
            case gameModeEvents(events: [GameModeEvent])
            case coopEvents(events: [CoopEvent], timeframes: [EventTimeframe])
        }
    }
    
    struct WatchScheduleWidgetsEntryView : View {
        var entry: Splatoon3_WatchTimelineProvider.Entry
        
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
                case .gameModeEvents(let events):
                    GameModeEntryView(gameMode: gameModeType, events: events, date: entry.date, isPreview: entry.isPreview).foregroundColor(.white).environmentObject(imageQuality)
                case .coopEvents(let events, let timeframes):
                    CoopEntryView(events: events, eventTimeframes: timeframes, date: entry.date).foregroundColor(.white).environmentObject(imageQuality)
                }
            }
        }
        
        var imageQuality : ImageQuality = {
            let quality = ImageQuality()
            quality.thumbnail = true
            return quality
        }()
    }
    
    
    func timelineForGameModeTimeline(_ modeTimeline: GameTimeline, for configuration: Splatoon3_WatchScheduleIntent) -> Timeline<GameModeEntry> {
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
    
    func timelineForCoopTimeline(_ coopTimeline: CoopTimeline, for configuration: Splatoon3_WatchScheduleIntent) -> Timeline<GameModeEntry> {
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
}

struct Splatoon2_WatchTimelineProvider: IntentTimelineProvider {
    
    enum TimelineType {
        case game(timeline: GameTimeline)
        case coop(timeline: CoopTimeline)
    }

    let scheduleFetcher = ScheduleFetcher()
    let imageLoaderManager = ImageLoaderManager()

    static var exampleSchedule: Splatoon2.Schedule {
        // if available, use cached schedule
        guard let cache = ScheduleFetcher.loadCachedSplatoon2Schedule() else { return Splatoon2.Schedule.example }
        return cache.schedule
    }
    
    static var exampleGameEvents : [GameModeEvent] {
        return Splatoon2_WatchTimelineProvider.exampleSchedule.regular.events
    }
    static var exampleCoopEvents : [CoopEvent] {
        return Splatoon2_WatchTimelineProvider.exampleSchedule.coop.events
    }

    // MARK: -
    func placeholder(in context: Context) -> GameModeEntry {
        return GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon2_WatchTimelineProvider.exampleGameEvents), configuration: Splatoon2_WatchScheduleIntent(), isPreview: true)
    }

    func getSnapshot(for configuration: Splatoon2_WatchScheduleIntent, in context: Context, completion: @escaping (GameModeEntry) -> ()) {
        if context.isPreview {
            switch configuration.scheduleType {
            case .regular, .unknown:
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon2_WatchTimelineProvider.exampleSchedule.regular.events), configuration: configuration, isPreview: true)
                completion(entry)
            case .ranked:
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon2_WatchTimelineProvider.exampleSchedule.ranked.events), configuration: configuration, isPreview: true)
                completion(entry)
            case .league:
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon2_WatchTimelineProvider.exampleSchedule.league.events), configuration: configuration, isPreview: true)
                completion(entry)
            case .salmonRun:
                let entry = GameModeEntry(date: Date(), events: .coopEvents(events: Splatoon2_WatchTimelineProvider.exampleSchedule.coop.events, timeframes: Splatoon2_WatchTimelineProvider.exampleSchedule.coop.otherTimeframes), configuration: configuration, isPreview: true)
                completion(entry)
                break
            }
            return
        }
        ScheduleFetcher.useSharedFolderForCaching = true

        scheduleFetcher.fetchSplatoon2Schedule(completion: { result in
            switch result {
            case .success(let schedule):
                
                switch configuration.scheduleType {
                case .regular, .unknown:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.regular.events), configuration: configuration)
                    completion(entry)
                case .ranked:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.ranked.events), configuration: configuration)
                    completion(entry)
                case .league:
                    let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.league.events), configuration: configuration)
                    completion(entry)
                case .salmonRun:
                    downloadImages(urls: schedule.coop.allWeaponImageURLs(), asJPEG: false, resizeSize: .resizeToWidth(64.0)) {
                        let entry = GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.events, timeframes: schedule.coop.otherTimeframes), configuration: configuration)
                        completion(entry)
                    }
                }
            case .failure(_):
                let entry = GameModeEntry(date: Date(), events: .gameModeEvents(events: Splatoon2_WatchTimelineProvider.exampleGameEvents), configuration: configuration)
                completion(entry)
                break
            }
        })
    }
    
    func getTimeline(for configuration: Splatoon2_WatchScheduleIntent, in context: Context, completion: @escaping (Timeline<GameModeEntry>) -> ()) {
        let mode = configuration.scheduleType
        ScheduleFetcher.useSharedFolderForCaching = true

        scheduleFetcher.fetchSplatoon2Schedule { result in
            switch result {
            case .success(let schedule):

                let selectedTimeline: TimelineType
                switch mode {
                case .regular:
                    selectedTimeline = .game(timeline: schedule.regular)
                case .ranked:
                    selectedTimeline = .game(timeline: schedule.ranked)
                case .league:
                    selectedTimeline = .game(timeline: schedule.league)
                case .salmonRun:
                    selectedTimeline = .coop(timeline: schedule.coop)
                default:
                    let entries: [GameModeEntry] = []
                    let timeline = Timeline(entries: entries, policy: .atEnd)
                    completion(timeline)
                    return
                }

                switch selectedTimeline {
                case .game(let timeline):
                    let timeline = timelineForGameModeTimeline(timeline, for: configuration)
                    completion(timeline)
                case .coop(let timeline):
                    downloadImages(urls: schedule.coop.allWeaponImageURLs(), asJPEG: false, resizeSize: .resizeToWidth(64.0)) {
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
    
    func recommendations() -> [IntentRecommendation<Splatoon2_WatchScheduleIntent>] {
        return [
            IntentRecommendation(intent: .turfWarConfig, description: "Splatoon 2 - Turf War"),
            IntentRecommendation(intent: .rankedConfig, description: "Splatoon 2 - Ranked"),
            IntentRecommendation(intent: .leagueConfig, description: "Splatoon 2 - League"),
            IntentRecommendation(intent: .salmonRunConfig, description: "Splatoon 2 - Salmon Run")
        ]
    }
    
    // MARK: -
    
    func downloadImages(urls: [URL], asJPEG: Bool = true, resizeSize: MultiImageLoader.ResizeOption? = nil, completion: @escaping ()->Void) {
        let destination = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName) ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let multiImageLoader = MultiImageLoader(urls: urls, directory: destination)
        multiImageLoader.storeAsJPEG = asJPEG
        multiImageLoader.resizeOption = resizeSize
        imageLoaderManager.imageLoaders.append(multiImageLoader)
        multiImageLoader.load {
            completion()
        }
    }

    // MARK: -
    
    struct GameModeEntry: TimelineEntry {
        let date: Date
        let events: GameModeEvents
        let configuration: Splatoon2_WatchScheduleIntent
        var isPreview: Bool = false
    }

    enum GameModeEvents {
        case gameModeEvents(events: [GameModeEvent])
        case coopEvents(events: [CoopEvent], timeframes: [EventTimeframe])
    }
    
    func timelineForGameModeTimeline(_ modeTimeline: GameTimeline, for configuration: Splatoon2_WatchScheduleIntent) -> Timeline<GameModeEntry> {
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
    
    func timelineForCoopTimeline(_ coopTimeline: CoopTimeline, for configuration: Splatoon2_WatchScheduleIntent) -> Timeline<GameModeEntry> {
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

    struct WatchScheduleWidgetsEntryView : View {
        var entry: Splatoon2_WatchTimelineProvider.Entry
        
        var gameModeType : GameModeType {
            switch entry.configuration.scheduleType {
            case .unknown, .regular:
                return .splatoon2(type: .turfWar)
            case .ranked:
                return .splatoon2(type: .ranked)
            case .league:
                return .splatoon2(type: .league)
            case .salmonRun:
                return .splatoon2(type: .salmonRun)
            }
        }

        var body: some View {
            
            Group {
                switch entry.events {
                case .gameModeEvents(let events):
                    GameModeEntryView(gameMode: gameModeType, events: events, date: entry.date, isPreview: entry.isPreview).foregroundColor(.white).environmentObject(imageQuality)
                case .coopEvents(let events, let timeframes):
                    CoopEntryView(events: events, eventTimeframes: timeframes, date: entry.date).foregroundColor(.white).environmentObject(imageQuality)

                }
            }
        }
        
        var imageQuality : ImageQuality = {
            let quality = ImageQuality()
            quality.thumbnail = true
            return quality
        }()
    }
}


@main
struct SplatoonWidgets: WidgetBundle {
   var body: some Widget {
       WatchSplatoon3ScheduleWidgets()
       WatchSplatoon2ScheduleWidgets()
   }
}

struct WatchSplatoon2ScheduleWidgets: Widget {

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kindWatchSplatoon2ScheduleWidgets, intent: Splatoon2_WatchScheduleIntent.self, provider: Splatoon2_WatchTimelineProvider()) { entry in
            Splatoon2_WatchTimelineProvider.WatchScheduleWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Splatoon 2")
        .description("Splatoon 2 Schedule.")
    }
}

struct WatchSplatoon3ScheduleWidgets: Widget {

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kindWatchSplatoon3ScheduleWidgets, intent: Splatoon3_WatchScheduleIntent.self, provider: Splatoon3_WatchTimelineProvider()) { entry in
            Splatoon3_WatchTimelineProvider.WatchScheduleWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Splatoon 3")
        .description("Splatoon 3 Schedule.")
    }
}

struct WatchScheduleWidgets_Previews: PreviewProvider {
    
    static let splat3Schedule = Splatoon3.Schedule.example
    static let splat2Schedule = Splatoon2.Schedule.example

    static var previews: some View {
        Splatoon2_WatchTimelineProvider.WatchScheduleWidgetsEntryView(entry: Splatoon2_WatchTimelineProvider.GameModeEntry(date: Date(), events: .gameModeEvents(events: splat2Schedule.ranked.events), configuration: .rankedConfig))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("2 - Ranked")

        Splatoon2_WatchTimelineProvider.WatchScheduleWidgetsEntryView(entry: Splatoon2_WatchTimelineProvider.GameModeEntry(date: Date(), events: .coopEvents(events: splat2Schedule.coop.events, timeframes: splat2Schedule.coop.otherTimeframes), configuration: .salmonRunConfig))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("2 - Salmon Run")

        Splatoon3_WatchTimelineProvider.WatchScheduleWidgetsEntryView(entry: Splatoon3_WatchTimelineProvider.GameModeEntry(date: Date(), events: .gameModeEvents(events: splat3Schedule.anarchyBattleSeries.events), configuration: .anarchyBattleOpenConfig))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("3 - Anarchy Open")

        Splatoon3_WatchTimelineProvider.WatchScheduleWidgetsEntryView(entry: Splatoon3_WatchTimelineProvider.GameModeEntry(date: Date(), events: .coopEvents(events: splat3Schedule.coop.events, timeframes: []), configuration: .salmonRunConfig))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
            .previewDisplayName("3 - Salmon Run")
    }
}

extension Splatoon2_WatchScheduleIntent {
    
    static var turfWarConfig: Splatoon2_WatchScheduleIntent {
        let regular = Splatoon2_WatchScheduleIntent()
        regular.scheduleType = .regular
        return regular
    }

    static var rankedConfig: Splatoon2_WatchScheduleIntent {
        let ranked = Splatoon2_WatchScheduleIntent()
        ranked.scheduleType = .ranked
        return ranked
    }

    static var leagueConfig: Splatoon2_WatchScheduleIntent {
        let league = Splatoon2_WatchScheduleIntent()
        league.scheduleType = .league
        return league
    }

    static var salmonRunConfig: Splatoon2_WatchScheduleIntent {
        let salmonRun = Splatoon2_WatchScheduleIntent()
        salmonRun.scheduleType = .salmonRun
        return salmonRun
    }
}

extension Splatoon3_WatchScheduleIntent {
    
    static var turfWarConfig: Splatoon3_WatchScheduleIntent {
        let turfWar = Splatoon3_WatchScheduleIntent()
        turfWar.scheduleType = .turfWar
        return turfWar
    }

    static var anarchyBattleOpenConfig: Splatoon3_WatchScheduleIntent {
        let anarchyOpen = Splatoon3_WatchScheduleIntent()
        anarchyOpen.scheduleType = .anarchyOpen
        return anarchyOpen
    }

    static var anarchyBattleSeriesConfig: Splatoon3_WatchScheduleIntent {
        let anarchySeries = Splatoon3_WatchScheduleIntent()
        anarchySeries.scheduleType = .anarchySeries
        return anarchySeries
    }

    static var leagueConfig: Splatoon3_WatchScheduleIntent {
        let league = Splatoon3_WatchScheduleIntent()
        league.scheduleType = .league
        return league
    }

    static var xConfig: Splatoon3_WatchScheduleIntent {
        let x = Splatoon3_WatchScheduleIntent()
        x.scheduleType = .x
        return x
    }

    static var salmonRunConfig: Splatoon3_WatchScheduleIntent {
        let salmonRun = Splatoon3_WatchScheduleIntent()
        salmonRun.scheduleType = .salmonRun
        return salmonRun
    }
}
