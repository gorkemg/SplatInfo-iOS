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
