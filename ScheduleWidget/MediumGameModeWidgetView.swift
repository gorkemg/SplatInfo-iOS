//
//  MediumGameModeWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 13.12.20.
//

import SwiftUI

struct MediumGameModeWidgetView : View {
    
    let gameMode: GameModeType
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

    var bottomSettings: EventViewSettings {
        let settings = self.eventViewSettings.copy()
        settings.settings.showTitle = false
        settings.settings.showRuleLogo = true
        return settings
    }

    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .topLeading) {

                gameMode.color
                gameMode.bgImage

                VStack(spacing: 8.0) {
                    
                    GameModeEventView(event: event, style: .large, date: date)
                        .environmentObject(topSettings)

                    if let nextEvent = nextEvent {
                        GameModeEventView(event: nextEvent, style: .threeColumns, date: date)
                            .environmentObject(bottomSettings)
                    }
                    
                }.padding(8)
                
            }
        }
    }

}
