//
//  MediumGameModeWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 13.12.20.
//

import SwiftUI

struct MediumGameModeWidgetView : View {
    
    let event: GameModeEvent
    var nextEvent: GameModeEvent? = nil
    let date: Date
    
    @EnvironmentObject var eventViewSettings: EventViewSettings

    var topSettings: EventViewSettings {
        let settings = self.eventViewSettings.copy()
        settings.settings.showTitle = true
        settings.settings.showRuleLogo = !event.mode.isTurfWar
        settings.settings.showGameLogoAt = .trailing
        return settings
    }

    var bottomSettings: EventViewSettings {
        let settings = self.eventViewSettings.copy()
        settings.settings.showTitle = false
        settings.settings.showRuleLogo = true
        return settings
    }

    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .topLeading) {

                event.mode.color
                event.mode.bgImage

                VStack(spacing: 8.0) {
                    
                    GameModeEventView(event: event, style: .large, date: date)
                    
                    if let nextEvent = nextEvent {
                        GameModeEventView(event: nextEvent, style: .threeColumns, date: date)
                    }
                    
                }.padding(8)
                
            }
        }
    }

}
