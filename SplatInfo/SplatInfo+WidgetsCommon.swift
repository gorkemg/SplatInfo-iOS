//
//  SplatInfo+WidgetsCommon.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 04.10.22.
//

import Foundation
import WidgetKit

let kindWatchSplatoon2ScheduleWidgets: String = "WatchSplatoon2ScheduleWidgets"
let kindWatchSplatoon3ScheduleWidgets: String = "WatchSplatoon3ScheduleWidgets"


extension GameTimeline {
    
    struct GameTimelineEvent {
        let date: Date      // widget update date
        let events: [GameModeEvent]
    }
    
    struct EventTimelineResult {
        let updatePolicy: TimelineReloadPolicy
        let events: [GameTimelineEvent]
    }
    
    func eventTimeline(startDate: Date, numberOfRemainingEventsBeforeUpdate: Int = 4) -> EventTimelineResult {
        let startDates = self.events.map({ $0.timeframe.startDate })
        print("StartDates: \(startDates)")
        let dates = ([startDate]+startDates).sorted()
        var entries: [GameTimelineEvent] = []
        for date in dates {
            let events = self.events.upcomingEventsAfterDate(date: date)
            if !events.isEmpty {
                let entry = GameTimelineEvent(date: date, events: events)
                entries.append(entry)
            }
        }
        var updatePolicy: TimelineReloadPolicy = .atEnd
        if let date = startDates.suffix(numberOfRemainingEventsBeforeUpdate).first, date > Date() {
            print("Refresh at: \(date)")
            updatePolicy = .after(date)
        }
        return .init(updatePolicy: updatePolicy, events: entries)
    }
}

extension CoopTimeline {
 
    struct CoopTimelineEvent {
        let date: Date      // widget update date
        let events: [CoopEvent]
        let timeframes: [EventTimeframe]
    }
    
    struct EventTimelineResult {
        let updatePolicy: TimelineReloadPolicy
        let events: [CoopTimelineEvent]
    }
    
    func eventTimeline(startDate: Date, numberOfRemainingEventsBeforeUpdate: Int = 2) -> EventTimelineResult {
        let startDates = self.events.map({ $0.timeframe.startDate })
        let endDates = self.events.map({ $0.timeframe.endDate })
        let dates = ([startDate]+startDates+endDates).sorted().unique()
        var entries: [CoopTimelineEvent] = []
        for date in dates {
            let events = self.events.upcomingEventsAfterDate(date: date)
            let eventTimeframes = self.otherTimeframes.upcomingTimeframesAfterDate(date: date)
            if !events.isEmpty {
                let entry = CoopTimelineEvent(date: date, events: events, timeframes: eventTimeframes)
                entries.append(entry)
            }
        }
        var updatePolicy: TimelineReloadPolicy = .atEnd
        if let date = startDates.suffix(numberOfRemainingEventsBeforeUpdate).first, date > Date() {
            print("Refresh at: \(date)")
            updatePolicy = .after(date)
        }
        return .init(updatePolicy: updatePolicy, events: entries)
    }
}
