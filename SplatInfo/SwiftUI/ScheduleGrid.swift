//
//  ScheduleGrid.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct ScheduleGrid: View {
    
    let schedule: Schedule
    
    let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400))
    ]

    var body: some View {
        ZStack {
            Image("bg-squids").resizable(resizingMode: .tile).ignoresSafeArea()
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 50) {
                    TimelineCard(timeline: .gameModeTimeline(timeline: schedule.gameModes.regular))
                    TimelineCard(timeline: .gameModeTimeline(timeline: schedule.gameModes.ranked))
                    TimelineCard(timeline: .gameModeTimeline(timeline: schedule.gameModes.league))
                    TimelineCard(timeline: .coopTimeline(timeline: schedule.coop))
                }
                .padding()
            }
        }
    }
}

struct CoopTimelineView: View {
    let coopTimeline: CoopTimeline
    
    var body: some View {
        VStack {
            if coopTimeline.detailedEvents.count > 0 {
                ForEach(0..<coopTimeline.detailedEvents.count) { i in
                    let event = coopTimeline.detailedEvents[i]
                    let state = event.timeframe.state(date: Date())
                    CoopEventView(event: event, style: i == 0 ? .large : .narrow, state: state)
                }
            }
        }
    }
}

struct GameModeTimelineView: View {
    let events : [GameModeEvent]
    
    var body: some View {
        if events.count > 0 {
            ForEach(0..<events.count) { i in
                GameModeEventView(gameModeEvent: events[i], style: i == 0 ? .large : .narrow)
            }
        }
    }
}

struct ScheduleGrid_Previews: PreviewProvider {

    static let exampleSchedule = Schedule.example
    
    static var previews: some View {
        Group {
            ScheduleGrid(schedule: exampleSchedule).previewDevice(PreviewDevice(rawValue: "iPad Air 2"))
            ScheduleGrid(schedule: exampleSchedule).previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }
}
