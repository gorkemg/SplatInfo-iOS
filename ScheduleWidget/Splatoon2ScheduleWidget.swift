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
            return [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryInline, .accessoryRectangular]
        }else{
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: SplatInfoWidgetBundle.kindSplatoon2ScheduleWidget, intent: Splatoon2_ScheduleIntent.self, provider: Splatoon2TimelineProvider()) { entry in
            Splatoon2TimelineProvider.ScheduleEntryView(entry: entry)
        }
        .supportedFamilies(supportedWidgetFamilies)
        .configurationDisplayName("Splatoon 2")
        .description("Splatoon 2 Schedules")
    }
}
