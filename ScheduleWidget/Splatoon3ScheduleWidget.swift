//
//  Splatoon3ScheduleWidget.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 19.09.22.
//

import SwiftUI
import WidgetKit

struct Splatoon3ScheduleWidget: Widget {

    var supportedWidgetFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryInline, .accessoryRectangular]
        }else{
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }

    var body: some WidgetConfiguration {
        
        IntentConfiguration(kind: kindSplatoon3ScheduleWidget, intent: Splatoon3_ScheduleIntent.self, provider: Splatoon3TimelineProvider()) { entry in
            Splatoon3TimelineProvider.ScheduleEntryView(entry: entry)
        }
        .supportedFamilies(supportedWidgetFamilies)
        .configurationDisplayName("Splatoon 3")
        .description("Splatoon 3 Schedules")
    }
}


struct Previews_Splatoon3ScheduleWidget_Previews: PreviewProvider {
    
    static let schedule = Splatoon3.Schedule.example
    
    static var regularEvents : [GameModeEvent] {
        return schedule.regular.events
    }

    static var anarchyOpenEvents : [GameModeEvent] {
        return schedule.anarchyBattleOpen.events
    }

    static var anarchySeriesEvents : [GameModeEvent] {
        return schedule.anarchyBattleSeries.events
    }

    static var leagueEvents : [GameModeEvent] {
        return schedule.league.events
    }

    static var xEvents : [GameModeEvent] {
        return schedule.x.events
    }

    static var coopEvents : [CoopEvent] {
        return schedule.coop.events
    }

    static var intent : Splatoon3_ScheduleIntent {
        return Splatoon3_ScheduleIntent()
    }

    static var intentWithDisplayNext : Splatoon3_ScheduleIntent {
        let intent = Splatoon3_ScheduleIntent()
        intent.displayNext = false
        return intent
    }
    

    static var previews: some View {

        Splatoon3TimelineProvider.ScheduleEntryView(entry: Splatoon3TimelineProvider.GameModeEntry(date: Date(), events: .gameModeEvents(events: leagueEvents), configuration: Splatoon3_ScheduleIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        Splatoon3TimelineProvider.ScheduleEntryView(entry: Splatoon3TimelineProvider.GameModeEntry(date: Date(), events: .coopEvents(events: coopEvents, timeframes: []), configuration: Splatoon3_ScheduleIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
