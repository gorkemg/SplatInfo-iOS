//
//  SmallCoopWidgetView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 31.10.20.
//

import SwiftUI

struct SmallCoopWidgetView : View {
    let event: CoopEvent
    let gear: CoopGear?
    let state: TimeframeActivityState

    @EnvironmentObject var eventViewSettings: EventViewSettings

    var settings: EventViewSettings {
        let settings = self.eventViewSettings.copy()
        settings.settings.showTitle = true
        settings.settings.showGameLogoAt = .trailing
        return settings
    }

    var body: some View {
        CoopEventView(event: event, gear: gear, style: .topBottom, state: state)
            .environmentObject(settings)
            .widgetBackground(backgroundView: topBottomBackground)
    }
    
    var topBottomBackground: some View {
        
        ZStack(alignment: .topLeading) {
            
            Color.coopModeColor
            
            Image("bg-spots").resizable(resizingMode: .tile)
            
            PillStageImage(stage: event.stage, namePosition: .hidden)
        }
        .environmentObject(settings)
    }
    
}
