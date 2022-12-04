//
//  SplatfestWidgetView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 15.11.22.
//

import SwiftUI
import WidgetKit

struct SplatfestWidget: View {
    
    let splatfest: Splatoon3.Schedule.Splatfest.Fest
    let event: GameModeEvent
    var nextEvent: GameModeEvent? = nil
    let date: Date

    @EnvironmentObject var eventViewSettings: EventViewSettings

    var topSettings: EventViewSettings {
        let settings = self.eventViewSettings.copy()
        settings.settings.showRuleLogo = !event.mode.isTurfWar
        settings.settings.showGameLogoAt = .trailing
        return settings
    }

    var body: some View {
        
        Text("")
    }
}
