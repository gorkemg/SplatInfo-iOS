//
//  SplatInfoWidgetBundle.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 19.09.22.
//

import WidgetKit
import SwiftUI

struct Splatoon2ScheduleWidget: Widget {

    var supportedWidgetFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            #if TARGET_OS_MACCATALYST
            return [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryInline, .accessoryRectangular]
            #else
            return [.systemSmall, .systemMedium, .systemLarge]
            #endif
        }else{
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kindSplatoon2ScheduleWidget, intent: Splatoon2_ScheduleIntent.self, provider: Splatoon2TimelineProvider()) { entry in
            Splatoon2TimelineProvider.ScheduleEntryView(entry: entry)
        }
        .supportedFamilies(supportedWidgetFamilies)
        .configurationDisplayName("Splatoon 2")
        .description("Splatoon 2 Schedules")
    }
}

struct Previews_Splatoon2ScheduleWidget_Previews: PreviewProvider {
    
    static let schedule = Splatoon2.Schedule.example
    
    static var intent : Splatoon2_ScheduleIntent {
        return Splatoon2_ScheduleIntent()
    }

    static var intentWithDisplayNext : Splatoon2_ScheduleIntent {
        let intent = Splatoon2_ScheduleIntent()
        intent.displayNext = true
        return intent
    }
    

    static var previews: some View {

        Splatoon2TimelineProvider.ScheduleEntryView(entry: Splatoon2TimelineProvider.GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.ranked.events), configuration: Splatoon2_ScheduleIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))

        Splatoon2TimelineProvider.ScheduleEntryView(entry: Splatoon2TimelineProvider.GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.events, timeframes: []), configuration: Splatoon2_ScheduleIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
