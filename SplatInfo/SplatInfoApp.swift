//
//  SplatInfoApp.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 15.10.20.
//

import SwiftUI

@main
struct SplatInfoApp: App {
    
    @State private var schedule = Schedule.empty
    private let scheduleFetcher = ScheduleFetcher()
    
    var body: some Scene {
        WindowGroup {
            ScheduleGrid(schedule: schedule).onAppear {
                scheduleFetcher.fetchSchedules { (schedule, error) in
                    guard let schedule = schedule else { return }
                    print(schedule)
                    self.schedule = schedule
                }
            }
        }
    }
}

struct ScheduleGrid: View {
    
    let schedule: Schedule
    
    let data = (1...4).map { "Item \($0)" }
    let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400))
    ]

    var body: some View {
        ZStack {
            Image("bg-squids").resizable(resizingMode: .tile).ignoresSafeArea()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 50) {
                    GameModeScheduleView(gameModeTimeline: schedule.regular)
                    GameModeScheduleView(gameModeTimeline: schedule.ranked)
                    GameModeScheduleView(gameModeTimeline: schedule.league)
                }
                .padding()
            }
        }
    }
}

struct GameModeScheduleView: View {
    let gameModeTimeline : GameModeTimeline
    var body: some View {
        VStack {
            GeometryReader { geometry in
                Text(gameModeTimeline.modeType.rawValue)
                    .padding()
            }
        }
        .frame(minWidth: 0, idealWidth: 300, maxWidth: .infinity, minHeight: 0, idealHeight: 400, maxHeight: .infinity, alignment: .center)
        .background(color)
    }
    
    var color : Color {
        switch gameModeTimeline.modeType {
        case .regular:
            return Color.green
        case .ranked:
            return Color.red
        case .league:
            return Color.pink
        }
    }
    
}



struct SplatInfoApp_Previews: PreviewProvider {
    
    let fakeSchedule = Schedule.empty
    
    static var previews: some View {
        Group {
            ScheduleGrid(schedule: Schedule.example).previewDevice(PreviewDevice(rawValue: "iPad Air 2"))
            ScheduleGrid(schedule: Schedule.example).previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        }
    }
}

