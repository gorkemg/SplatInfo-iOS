//
//  SplatInfoApp.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 15.10.20.
//

import SwiftUI

@main
struct SplatInfoApp: App {
    
    private let scheduleFetcher = ScheduleFetcher()
    @State var schedule = Schedule.empty
    
    var body: some Scene {
        WindowGroup {
            ScheduleGrid(schedule: schedule)
                .onAppear {
                    scheduleFetcher.fetchGameModeTimelines { (gameModeTimelines, error) in
                        schedule = scheduleFetcher.schedule
                    }
                    scheduleFetcher.fetchCoopTimeline { (coopTimeline, error) in
                        schedule = scheduleFetcher.schedule
                    }
                }
        }
    }
}
