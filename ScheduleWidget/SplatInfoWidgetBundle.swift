//
//  Schedule.swift
//  Schedule
//
//  Created by Görkem Güclü on 23.10.20.
//

import WidgetKit
import SwiftUI
import Intents

@main
struct SplatInfoWidgetBundle: WidgetBundle {
    
    // MARK: - View
    @WidgetBundleBuilder
    var body: some Widget {
        Splatoon3ScheduleWidget()
        Splatoon2ScheduleWidget()
    }
}


//struct Schedule_Previews: PreviewProvider {
//
//    static let schedule = Splatoon2.Schedule.example
//
//    static var regularEvents : [GameModeEvent] {
//        return schedule.regular.events
//    }
//
//    static var rankedEvents : [GameModeEvent] {
//        return schedule.ranked.events
//    }
//
//    static var leagueEvents : [GameModeEvent] {
//        return schedule.league.events
//    }
//
//    static var intent : Splatoon2_ScheduleIntent {
//        return Splatoon2_ScheduleIntent()
//    }
//
//    static var intentWithDisplayNext : Splatoon2_ScheduleIntent {
//        let intent = Splatoon2_ScheduleIntent()
//        intent.displayNext = true
//        return intent
//    }
//
//
//    static var previews: some View {
//
//        Splatoon2TimelineProvider.ScheduleEntryView(entry: Splatoon2TimelineProvider.GameModeEntry(date: Date(), events: .gameModeEvents(events: regularEvents), configuration: Splatoon2_ScheduleIntent()))
//            .previewContext(WidgetPreviewContext(family: .systemMedium))
//
////        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.detailedEvents, timeframes: schedule.coop.eventTimeframes), configuration: ConfigurationIntent()))
////            .previewContext(WidgetPreviewContext(family: .systemLarge))
//
//        //        ScheduleEntryView(entry: GameModeEntry(date: Date(), events: .coopEvents(events: schedule.coop.detailedEvents, timeframes: schedule.coop.eventTimeframes), configuration: ConfigurationIntent()))
////            .previewContext(WidgetPreviewContext(family: .systemExtraLarge))
//
//    }
//}
