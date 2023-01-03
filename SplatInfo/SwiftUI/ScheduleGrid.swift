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
     
    let eventViewSettings: EventViewSettings

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
                                .splat1Font(size: 30)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .padding(.vertical, 4.0)
                        .padding(.horizontal, 12.0)
                        .background( selectedSchedules.contains(.splatoon3) ? .blue : .clear)
                        .cornerRadius(20)

                        Button {
                            print("Splatoon 2 pressed")
                            if selectedSchedules.contains(.splatoon2) {
                                selectedSchedules.remove(.splatoon2)
                            }else{
                                selectedSchedules.insert(.splatoon2)
                            }
                        } label: {
                            Text("Splatoon 2")
                                .splat1Font(size: 30)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                        .padding(.vertical, 4.0)
                        .padding(.horizontal, 12.0)
                        .background( selectedSchedules.contains(.splatoon2) ? .pink : .clear)
                        .cornerRadius(20)
                    }
                    
                    if selectedSchedules.contains(.splatoon3) {
                        
                        VStack{
                            Image("Splatoon3_number_icon")
                            LazyVGrid(columns: columns, spacing: 50) {
                                if case .active(_) = splatoon3Schedule.splatfest.activity {
                                    // Splatfest not currently active
                                    if let fest = splatoon3Schedule.splatfest.fest {
                                        Splatoon3TimelineCard(timeline: .game(mode: .splatfest(fest: fest), timeline: splatoon3Schedule.splatfest.timeline))
                                            .environmentObject(eventViewSettings)

                                    }else{
                                        // Splatfest scheduled
                                    }
                                }else{
                                    // Splatfest not currently active
                                    
                                    Splatoon3TimelineCard(timeline: .game(mode: .turfWar, timeline: splatoon3Schedule.regular))
                                        .environmentObject(eventViewSettings)

                                    Splatoon3TimelineCard(timeline: .game(mode: .anarchyBattleOpen, timeline: splatoon3Schedule.anarchyBattleOpen))
                                        .environmentObject(eventViewSettings)

                                    Splatoon3TimelineCard(timeline: .game(mode: .anarchyBattleSeries, timeline: splatoon3Schedule.anarchyBattleSeries))
                                        .environmentObject(eventViewSettings)

                                    Splatoon3TimelineCard(timeline: .game(mode: .league, timeline: splatoon3Schedule.league))
                                        .environmentObject(eventViewSettings)

                                    Splatoon3TimelineCard(timeline: .game(mode: .x, timeline: splatoon3Schedule.x))
                                        .environmentObject(eventViewSettings)

                                }
                                Splatoon3TimelineCard(timeline: .coop(timeline: splatoon3Schedule.coopWithBigRun))
                                    .environmentObject(eventViewSettings)

                            }
                        }
                    }

                    if selectedSchedules.contains(.splatoon2) {
                        VStack{
                            Image("Splatoon2_number_icon")
                            LazyVGrid(columns: columns, spacing: 50) {
                                Splatoon2TimelineCard(timeline: .game(mode: .turfWar, timeline: splatoon2Schedule.regular))
                                    .environmentObject(eventViewSettings)

                                Splatoon2TimelineCard(timeline: .game(mode: .ranked, timeline: splatoon2Schedule.ranked))
                                    .environmentObject(eventViewSettings)

                                Splatoon2TimelineCard(timeline: .game(mode: .league, timeline: splatoon2Schedule.league))
                                    .environmentObject(eventViewSettings)

                                Splatoon2TimelineCard(timeline: .coop(timeline: splatoon2Schedule.coop))
                                    .environmentObject(eventViewSettings)

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
    var numberOfEventsDisplayed: Int = 4

    @EnvironmentObject var eventViewSettings: EventViewSettings

    var largeEventViewSettings: EventViewSettings {
        var regularSettings = eventViewSettings.settings
        regularSettings.showMonthlyGear = true
        regularSettings.showTitle = false
        return EventViewSettings(settings: regularSettings)
    }

    var smallEventViewSettings: EventViewSettings {
        var regularSettings = eventViewSettings.settings
        regularSettings.showMonthlyGear = false
        regularSettings.showTitle = false
        return EventViewSettings(settings: regularSettings)
    }

    
    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            VStack(alignment: .leading, spacing: 16.0) {
                if !coopTimeline.events.isEmpty {
                    ForEach(coopTimeline.events.prefix(numberOfEventsDisplayed).indices, id: \.self) { i in
                        let event = coopTimeline.events[i]
                        let state = event.timeframe.state(date: Date())
                        let style: CoopEventView.Style = i == 0 ? .large : .sideBySide
                        CoopEventView(event: event, gear: coopTimeline.gear, style: style, state: state)
                            .environmentObject(i == 0 ? largeEventViewSettings : smallEventViewSettings)
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
    
    @EnvironmentObject var eventViewSettings: EventViewSettings

    func topSettings(event: GameModeEvent) -> EventViewSettings {
        let settings = self.eventViewSettings.copy()
        settings.settings.showModeLogo = false
        return settings
    }

    func bottomSettings(event: GameModeEvent) -> EventViewSettings {
        let settings = self.eventViewSettings.copy()
        settings.settings.showTitle = false
        return settings
    }

    var body: some View {
        if events.count > 0 {
            ForEach(0..<events.count, id: \.self) { i in
                let event = events[i]
                GameModeEventView(gameMode: mode, event: event, style: i == 0 ? .large : .threeColumns, date: Date())
                    .environmentObject(i == 0 ? topSettings(event: event) : bottomSettings(event: event))
            }
        }
    }
}

struct ScheduleGrid_Previews: PreviewProvider {
    
    @State static var exampleSchedule = Splatoon2.Schedule.example
    @State static var exampleSchedule3 = Splatoon3.Schedule.example

    static var previews: some View {
        Group {
            ScheduleGrid(splatoon2Schedule: $exampleSchedule, splatoon3Schedule: $exampleSchedule3, eventViewSettings: eventViewSettings)
        }
        .previewInterfaceOrientation(.portrait)
        .previewDevice("iPhone 14 Pro Max")
        .previewLayout(.device)
    }
    
    static var eventViewSettings : EventViewSettings {
        let eventViewSettings = EventViewSettings()
        eventViewSettings.settings.useThumbnailQuality = false
        return eventViewSettings
    }
}
