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
        ZStack {
            Image("bg-squids").resizable(resizingMode: .tile).ignoresSafeArea()
            
            if let event = event {
                switch widgetFamily {
                case .systemSmall:
                    SmallGameModeWidgetView(event: event, nextEvent: nextEvent)
                case .systemMedium:
                    SmallGameModeWidgetView(event: event, nextEvent: nextEvent)
                case .systemLarge:
                    SmallGameModeWidgetView(event: event, nextEvent: nextEvent)
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

    var body: some View {
        if let event = event {
            SmallCoopWidgetView(event: event)
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
    var nextEvent: CoopEvent? {
        if let currentEvent = self.event, let index = events.firstIndex(where: { $0 == currentEvent }), events.count > index+1 {
            return events[(index+1)]
        }
        return nil
    }
}

struct SmallGameModeWidgetView : View {
    let event: GameModeEvent
    var nextEvent: GameModeEvent? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {

            event.mode.type.color

            Image("splatoon-card-bg").resizable(resizingMode: .tile)

            GeometryReader { geometry in
                VStack(spacing: 0.0) {
                    ForEach(event.stages, id: \.id) { stage in
                        if let image = stage.image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height/2)
                                .clipped()
                        }
                    }
                }.cornerRadius(10.0)
            }
            
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 0.0) {
                
                VStack(alignment: .leading, spacing: 0.0) {
                    HStack {
                        Image(event.mode.type.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 20)
                        Text(event.rule.name).splat2Font(size: 14).minimumScaleFactor(0.5)
                    }
                }
                                
                Spacer()
                
                VStack(alignment: .leading, spacing: 0.0) {
                    if let next = nextEvent {
                        Text(event.mode.type != .regular ? next.rule.name : "Changes")
                        + relativeTimeText(event: next)
                    }
                }.splat2Font(size: 10).lineLimit(1).minimumScaleFactor(0.5)
            }.padding(.horizontal, 10.0).padding(.vertical, 4)
        }
    }

    func relativeTimeText(event: GameModeEvent) -> Text {
        switch event.timeframe.status(date: Date()) {
        case .active:
            return Text(" since ") + Text(event.timeframe.startDate, style: .relative)
        case .soon:
            return Text(" in ") + Text(event.timeframe.startDate, style: .relative)
        case .over:
            return Text(" ended ") + Text(event.timeframe.endDate, style: .relative) + Text(" ago")
        }
    }
}

struct SmallCoopWidgetView : View {
    let event: CoopEvent
    var date: Date = Date()

    var body: some View {
        ZStack(alignment: .topLeading) {

            event.color

            Image("bg-spots").resizable(resizingMode: .tile)

            GeometryReader { geometry in
                VStack(spacing: 0.0) {
                    if let image = event.stage.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                }.cornerRadius(10.0)
            }
            
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 0.0) {
                
                VStack(alignment: .leading, spacing: 0.0) {
                    HStack {
                        Image(event.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 20)
                        Text(event.modeName).splat2Font(size: 14).minimumScaleFactor(0.5).lineSpacing(0)
                    }
                    Text(event.stage.name).splat2Font(size: 10)
                }

                Spacer()
                
                VStack(alignment: .leading, spacing: 2.0) {
                    HStack {
                        currentActivityTextView
                        RelativeTimeframeView(timeframe: event.timeframe, date: date)
                    }.splat2Font(size: 12)
                    
                    ActivityTimeFrameView(event: event, date: date).lineLimit(1).minimumScaleFactor(0.5)
                    HStack(spacing: 4.0) {
                        Group {
                            WeaponsList(event: event)
                                .shadow(color: .black, radius: 2, x: 0.0, y: 1.0)
                                .frame(maxHeight: 24, alignment: .leading)
                        }
                        
                        Spacer()
                    }
                }.lineSpacing(0)
            }.padding(.horizontal, 10.0).padding(.vertical, 4.0)
        }.foregroundColor(.white)
    }
    
    var currentActivityTextView : some View {
        HStack {
            Text(currentActivityText)
        }.padding(.horizontal, 4.0).background(currentActivityColor).cornerRadius(5.0)
    }
    
    var currentActivityText : String {
        return event.timeframe.status(date: date).activityText
    }
    var currentActivityColor : Color {
        switch event.timeframe.status(date: date) {
        case .active:
            return Color.coopModeColor
        case .soon:
            return Color.black
        case .over:
            return Color.gray
        }
    }
}

struct ActivityTimeFrameView : View {
    let event: CoopEvent
    var date: Date = Date()

    var body: some View {
        switch event.timeframe.status(date: date) {
        case .active:
            Text("- \(timeframeEndString)").splat2Font(size: 10)
        case .soon:
            Text("\(timeframeStartString) - \(timeframeEndString)").splat2Font(size: 10)
        case .over:
            Text("- \(timeframeEndString)").splat2Font(size: 10)
        }
    }
    var timeframeStartString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: event.timeframe.startDate)
    }
    var timeframeEndString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: event.timeframe.endDate)
    }

}

extension TimeframeActivityStatus {
    var activityText: String {
        switch self {
        case .active:
            return "Open!"
        case .soon:
            return "Soon!"
        case .over:
            return "Ended!"
        }
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
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: rankedEvents), configuration: intent))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: rankedEvents), configuration: intentWithDisplayNext))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .gameModeEvents(events: leagueEvents), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.detailedEvents, timeframes: schedule.coop.eventTimeframes), configuration: intent))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.detailedEvents, timeframes: schedule.coop.eventTimeframes), configuration: intentWithDisplayNext))
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
