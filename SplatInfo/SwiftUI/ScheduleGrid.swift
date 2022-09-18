//
//  ScheduleGrid.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct ScheduleGrid: View {
    
    let splatoon2Schedule: Splatoon2Schedule
    
    @State private var selectedSchedules: Set<Game> = Set(arrayLiteral: .splatoon2,.splatoon3)
        
    let columns = [
        GridItem(.adaptive(minimum: 300, maximum: .infinity))
    ]

    var body: some View {
        ZStack {
            Image("bg-squids").resizable(resizingMode: .tile).ignoresSafeArea()
            ScrollView(.vertical) {
                
                VStack(alignment: .leading, spacing: 20.0) {
                    
                    HStack(alignment: .center, spacing: 20.0) {

                        Button {
                            print("Splatoon 3 pressed")
                            if selectedSchedules.contains(.splatoon3) {
                                selectedSchedules.remove(.splatoon3)
                            }else{
                                selectedSchedules.insert(.splatoon3)
                            }
                        } label: {
                            Text("Splatoon 3")
                        }
                        .padding(.vertical, 4.0)
                        .padding(.horizontal, 12.0)
                        .background( selectedSchedules.contains(.splatoon3) ? .blue : .clear)
                        .cornerRadius(20)
                        .splat2Font(size: 30)

                        Button {
                            print("Splatoon 2 pressed")
                            if selectedSchedules.contains(.splatoon2) {
                                selectedSchedules.remove(.splatoon2)
                            }else{
                                selectedSchedules.insert(.splatoon2)
                            }
                        } label: {
                            Text("Splatoon 2")
                        }
                        .padding(.vertical, 4.0)
                        .padding(.horizontal, 12.0)
                        .background( selectedSchedules.contains(.splatoon2) ? .pink : .clear)
                        .cornerRadius(20)
                        .splat2Font(size: 30)
                    }
                    
                    LazyVGrid(columns: columns, spacing: 50) {
                            TimelineCard(timeline: .gameModeTimeline(timeline: splatoon2Schedule.gameModes.regular))
                            TimelineCard(timeline: .gameModeTimeline(timeline: splatoon2Schedule.gameModes.ranked))
                            TimelineCard(timeline: .gameModeTimeline(timeline: splatoon2Schedule.gameModes.league))
                            TimelineCard(timeline: .coopTimeline(timeline: splatoon2Schedule.coop))
                    }
                }.padding()
            }
        }
        .foregroundColor(.white)
    }
}

struct CoopTimelineView: View {
    let coopTimeline: CoopTimeline
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            VStack(alignment: .leading, spacing: 16.0) {
                if coopTimeline.detailedEvents.count > 0 {
                    ForEach(0..<coopTimeline.detailedEvents.count, id: \.self) { i in
                        let event = coopTimeline.detailedEvents[i]
                        let state = event.timeframe.state(date: Date())
                        let style: CoopEventView.Style = i == 0 ? .large : .sideBySide
                        let height: CGFloat? = nil //i == 0 ? 250.0 : nil
                        CoopEventView(event: event, style: style, state: state, showTitle: i == 0, height: height)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 4.0) {
                if coopTimeline.eventTimeframes.count > 2 {
                    let eventTimeframes = coopTimeline.eventTimeframes[2...]
                    ForEach(eventTimeframes, id: \.self) { timeframe in
                        TimeframeView(timeframe: timeframe, datesStyle: .always, fontSize: 12)
                    }
                }
            }
        }
    }
}

struct GameModeTimelineView: View {
    let events : [Splatoon2.GameModeEvent]
    
    var body: some View {
        if events.count > 0 {
            ForEach(0..<events.count, id: \.self) { i in
                GameModeEventView(event: events[i], style: i == 0 ? .large : .medium)
            }
        }
    }
}

struct CoopTimelineView_Previews: PreviewProvider {
    
    static let exampleSchedule = Splatoon2Schedule.example
    
    static var previews: some View {
        Group {
            ScheduleGrid(splatoon2Schedule: exampleSchedule)
//            CoopTimelineView(coopTimeline: Splatoon2Schedule.example.coop)
                .environmentObject(imageQuality)
        }
        .previewInterfaceOrientation(.landscapeRight)
        .previewDevice("iPad Air (5th generation)")
        .previewLayout(.device)
    }
    
    static var imageQuality : ImageQuality {
        let quality = ImageQuality()
        quality.thumbnail = false
        return quality
    }
}
