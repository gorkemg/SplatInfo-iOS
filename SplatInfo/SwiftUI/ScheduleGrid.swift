//
//  ScheduleGrid.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct ScheduleGrid: View {
    
    @Binding var splatoon2Schedule: Splatoon2.Schedule
    @Binding var splatoon3Schedule: Splatoon3.Schedule

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
                    
                    if selectedSchedules.contains(.splatoon3) {
                        
                        VStack{
                            Text("Splatoon 3").splat2Font(size: 20)
                            LazyVGrid(columns: columns, spacing: 50) {
                                if case .active(_) = splatoon3Schedule.splatfest.activity {
                                    // Splatfest not currently active
                                    if let fest = splatoon3Schedule.splatfest.fest {
                                        Splatoon3TimelineCard(timeline: .game(mode: .splatfest(fest: fest), timeline: splatoon3Schedule.splatfest.timeline))
                                    }else{
                                        // Splatfest scheduled
                                    }
                                }else{
                                    // Splatfest not currently active
                                    
                                    Splatoon3TimelineCard(timeline: .game(mode: .turfWar, timeline: splatoon3Schedule.regular))
                                    Splatoon3TimelineCard(timeline: .game(mode: .anarchyBattleOpen, timeline: splatoon3Schedule.anarchyBattleOpen))
                                    Splatoon3TimelineCard(timeline: .game(mode: .anarchyBattleSeries, timeline: splatoon3Schedule.anarchyBattleSeries))
                                    Splatoon3TimelineCard(timeline: .game(mode: .league, timeline: splatoon3Schedule.league))
                                    Splatoon3TimelineCard(timeline: .game(mode: .x, timeline: splatoon3Schedule.x))
                                }
                                Splatoon3TimelineCard(timeline: .coop(timeline: splatoon3Schedule.coop))
                            }
                        }
                    }

                    if selectedSchedules.contains(.splatoon2) {
                        VStack{
                            Text("Splatoon 2").splat2Font(size: 20)
                            LazyVGrid(columns: columns, spacing: 50) {
                                Splatoon2TimelineCard(timeline: .game(mode: .turfWar, timeline: splatoon2Schedule.regular))
                                Splatoon2TimelineCard(timeline: .game(mode: .ranked, timeline: splatoon2Schedule.ranked))
                                Splatoon2TimelineCard(timeline: .game(mode: .league, timeline: splatoon2Schedule.league))
                                Splatoon2TimelineCard(timeline: .coop(timeline: splatoon2Schedule.coop))
                            }
                        }
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
                if !coopTimeline.events.isEmpty {
                    ForEach(0..<coopTimeline.events.prefix(4).count, id: \.self) { i in
                        let event = coopTimeline.events[i]
                        let state = event.timeframe.state(date: Date())
                        let style: CoopEventView.Style = i == 0 ? .large : .sideBySide
                        let height: CGFloat? = nil //i == 0 ? 250.0 : nil
                        CoopEventView(event: event, style: style, state: state, showTitle: false, height: height)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 4.0) {
                if coopTimeline.otherTimeframes.count > 2 {
                    let eventTimeframes = coopTimeline.otherTimeframes.suffix(from: 2)
                    ForEach(eventTimeframes, id: \.self) { timeframe in
                        TimeframeView(timeframe: timeframe, datesStyle: .always, fontSize: 12)
                    }
                }
            }
        }
    }
}

struct GameModeTimelineView: View {
    let mode: GameModeType
    let events : [GameModeEvent]
    
    var body: some View {
        if events.count > 0 {
            ForEach(0..<events.count, id: \.self) { i in
                let event = events[i]
                GameModeEventView(event: event, style: i == 0 ? .large : .threeColumns, isRuleLogoVisible: !event.mode.isTurfWar)
            }
        }
    }
}

struct CoopTimelineView_Previews: PreviewProvider {
    
    @State static var exampleSchedule = Splatoon2.Schedule.example
    @State static var exampleSchedule3 = Splatoon3.Schedule.example

    static var previews: some View {
        Group {
            ScheduleGrid(splatoon2Schedule: $exampleSchedule, splatoon3Schedule: $exampleSchedule3)
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
