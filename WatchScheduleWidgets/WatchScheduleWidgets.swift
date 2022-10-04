//
//  WatchScheduleWidgets.swift
//  WatchScheduleWidgets
//
//  Created by Görkem Güclü on 03.10.22.
//

import WidgetKit
import SwiftUI
import Intents

struct Splatoon3_TimelineProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: Splatoon3_ScheduleIntent())
    }

    func getSnapshot(for configuration: Splatoon3_ScheduleIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: Splatoon3_ScheduleIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func recommendations() -> [IntentRecommendation<Splatoon3_ScheduleIntent>] {
        return [
            IntentRecommendation(intent: .turfWarConfig, description: "Splatoon 3 - Turf War"),
            IntentRecommendation(intent: .anarchyBattleOpenConfig, description: "Splatoon 3 - Anarchy Battle Open"),
            IntentRecommendation(intent: .anarchyBattleSeriesConfig, description: "Splatoon 3 - Anarchy Battle Series"),
            IntentRecommendation(intent: .leagueConfig, description: "Splatoon 3 - League"),
            IntentRecommendation(intent: .xConfig, description: "Splatoon 3 - X"),
            IntentRecommendation(intent: .salmonRunConfig, description: "Splatoon 3 - Salmon Run")
        ]
    }
    
    struct SimpleEntry: TimelineEntry {
        let date: Date
        let configuration: Splatoon3_ScheduleIntent
    }
    
    struct WatchScheduleWidgetsEntryView : View {
        var entry: Splatoon3_TimelineProvider.Entry
        
        var body: some View {
            Text(entry.date, style: .time)
        }
    }
}

struct Splatoon2_TimelineProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: Splatoon2_ScheduleIntent())
    }
    
    func getSnapshot(for configuration: Splatoon2_ScheduleIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }
    
    func getTimeline(for configuration: Splatoon2_ScheduleIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    func recommendations() -> [IntentRecommendation<Splatoon2_ScheduleIntent>] {
        return [
            IntentRecommendation(intent: .turfWarConfig, description: "Splatoon 2 - Turf War"),
            IntentRecommendation(intent: .rankedConfig, description: "Splatoon 2 - Ranked"),
            IntentRecommendation(intent: .leagueConfig, description: "Splatoon 2 - League"),
            IntentRecommendation(intent: .salmonRunConfig, description: "Splatoon 2 - Salmon Run")
        ]
    }
    
    struct SimpleEntry: TimelineEntry {
        let date: Date
        let configuration: Splatoon2_ScheduleIntent
        
    }
    
    struct WatchScheduleWidgetsEntryView : View {
        var entry: Splatoon2_TimelineProvider.Entry

        var body: some View {
            Text(entry.date, style: .time)
        }
    }
}


@main
struct SplatoonWidgets: WidgetBundle {
   var body: some Widget {
       WatchScheduleWidgets()
       WatchSchedule2Widgets()
   }
}

struct WatchScheduleWidgets: Widget {
    let kind: String = "WatchScheduleWidgets"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: Splatoon2_ScheduleIntent.self, provider: Splatoon2_TimelineProvider()) { entry in
            Splatoon2_TimelineProvider.WatchScheduleWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Splatoon 2")
        .description("Splatoon 2 Schedule.")
    }
}

struct WatchSchedule2Widgets: Widget {
    let kind: String = "WatchScheduleWidgets2"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: Splatoon3_ScheduleIntent.self, provider: Splatoon3_TimelineProvider()) { entry in
            Splatoon3_TimelineProvider.WatchScheduleWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Splatoon 3")
        .description("Splatoon 3 Schedule.")
    }
}

struct WatchScheduleWidgets_Previews: PreviewProvider {
    static var previews: some View {
        Splatoon2_TimelineProvider.WatchScheduleWidgetsEntryView(entry: Splatoon2_TimelineProvider.SimpleEntry(date: Date(), configuration: .rankedConfig))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))

        Splatoon2_TimelineProvider.WatchScheduleWidgetsEntryView(entry: Splatoon2_TimelineProvider.SimpleEntry(date: Date(), configuration: .salmonRunConfig))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))

        Splatoon3_TimelineProvider.WatchScheduleWidgetsEntryView(entry: Splatoon3_TimelineProvider.SimpleEntry(date: Date(), configuration: .anarchyBattleOpenConfig))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))

        Splatoon3_TimelineProvider.WatchScheduleWidgetsEntryView(entry: Splatoon3_TimelineProvider.SimpleEntry(date: Date(), configuration: .salmonRunConfig))
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}

extension Splatoon2_ScheduleIntent {
    
    static var turfWarConfig: Splatoon2_ScheduleIntent {
        let regular = Splatoon2_ScheduleIntent()
        regular.scheduleType = "regular"
        return regular
    }

    static var rankedConfig: Splatoon2_ScheduleIntent {
        let ranked = Splatoon2_ScheduleIntent()
        ranked.scheduleType = "ranked"
        return ranked
    }

    static var leagueConfig: Splatoon2_ScheduleIntent {
        let league = Splatoon2_ScheduleIntent()
        league.scheduleType = "league"
        return league
    }

    static var salmonRunConfig: Splatoon2_ScheduleIntent {
        let salmonRun = Splatoon2_ScheduleIntent()
        salmonRun.scheduleType = "salmonRun"
        return salmonRun
    }
}

extension Splatoon3_ScheduleIntent {
    
    static var turfWarConfig: Splatoon3_ScheduleIntent {
        let turfWar = Splatoon3_ScheduleIntent()
        turfWar.scheduleType = "turfWar"
        return turfWar
    }

    static var anarchyBattleOpenConfig: Splatoon3_ScheduleIntent {
        let open = Splatoon3_ScheduleIntent()
        open.scheduleType = "anarchyOpen"
        return open
    }

    static var anarchyBattleSeriesConfig: Splatoon3_ScheduleIntent {
        let series = Splatoon3_ScheduleIntent()
        series.scheduleType = "anarchySeries"
        return series
    }

    static var leagueConfig: Splatoon3_ScheduleIntent {
        let league = Splatoon3_ScheduleIntent()
        league.scheduleType = "league"
        return league
    }

    static var xConfig: Splatoon3_ScheduleIntent {
        let x = Splatoon3_ScheduleIntent()
        x.scheduleType = "x"
        return x
    }

    static var salmonRunConfig: Splatoon3_ScheduleIntent {
        let salmonRun = Splatoon3_ScheduleIntent()
        salmonRun.scheduleType = "salmonRun"
        return salmonRun
    }
}
