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
        
        IntentConfiguration(kind: SplatInfoWidgetBundle.kindSplatoon3ScheduleWidget, intent: Splatoon3_ScheduleIntent.self, provider: Splatoon3TimelineProvider()) { entry in
            Splatoon3TimelineProvider.ScheduleEntryView(entry: entry)
        }
        .supportedFamilies(supportedWidgetFamilies)
        .configurationDisplayName("Splatoon 3")
        .description("Splatoon 3 Schedules")
    }
}
