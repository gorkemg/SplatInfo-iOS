//
//  Splatoon3ScheduleWidget.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 19.09.22.
//

import SwiftUI
import WidgetKit

//struct Splatoon3ScheduleWidget: Widget {
//    let kind: String = "Splatoon3ScheduleWidget"
//
//    var supportedWidgetFamilies: [WidgetFamily] {
//        if #available(iOSApplicationExtension 16.0, *) {
//            return [.systemSmall, .systemMedium, .systemLarge, .accessoryCircular, .accessoryInline, .accessoryRectangular]
//        }else{
//            return [.systemSmall, .systemMedium, .systemLarge]
//        }
//    }
//
//    var body: some WidgetConfiguration {
//        
//        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
//            ScheduleEntryView(entry: entry)
//        }
//        .supportedFamilies(supportedWidgetFamilies)
//        .configurationDisplayName("SplatInfo Widget")
//        .description("Splatoon 3 schedules")
//    }
//}
