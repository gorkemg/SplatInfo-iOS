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
#if os(watchOS)
        return [.accessoryCircular, .accessoryInline, .accessoryRectangular, .accessoryCorner]
#else
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryInline, .accessoryRectangular]
        }else{
            return [.systemSmall, .systemMedium, .systemLarge]
        }
#endif
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


@available(iOSApplicationExtension 17.0, *)
struct Previews_Splatoon3ScheduleWidget_Previews: PreviewProvider {
    
    static let schedule = Splatoon3.Schedule.example20231207
    
    static var intent : Splatoon3_ScheduleIntent {
        return Splatoon3_ScheduleIntent()
    }

    static var intentWithDisplayNext : Splatoon3_ScheduleIntent {
        let intent = Splatoon3_ScheduleIntent()
        intent.displayNext = false
        return intent
    }
 
    static var previews: some View {

#if !os(watchOS)
        Splatoon3TimelineProvider.ScheduleEntryView(entry: Splatoon3TimelineProvider.GameModeEntry(date: Date(), events: .gameModeEvents(events: schedule.anarchyBattleSeries.events), configuration: Splatoon3_ScheduleIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Anarchy Battle")

        Splatoon3TimelineProvider.ScheduleEntryView(entry: Splatoon3TimelineProvider.GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.events, timeframes: [], gear: schedule.coop.gear), configuration: Splatoon3_ScheduleIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Salmon Run")
        
        Splatoon3TimelineProvider.ScheduleEntryView(entry: Splatoon3TimelineProvider.GameModeEntry(date: Date(), events: .splatfest(splatfest: schedule.splatfest), configuration: Splatoon3_ScheduleIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Splatfest")

#endif
    }

}
