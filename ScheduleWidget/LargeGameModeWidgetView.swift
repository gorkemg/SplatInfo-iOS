//
//  LargeGameModeWidgetView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 05.11.20.
//

import SwiftUI

struct LargeGameModeWidgetView : View {
    let event: GameModeEvent
    var nextEvents: [GameModeEvent]
    let date: Date                      // widget update date
        
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
        return settings
    }

    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .topLeading) {

                event.mode.color
                event.mode.bgImage

                VStack {

                    GameModeEventView(event: event, style: .large, date: date)
                        .environmentObject(topSettings)
                    
                    ForEach(nextEvents.indices, id: \.self) { i in
                        let nextEvent = nextEvents[i]
                        GameModeEventView(event: nextEvent, style: .threeColumns, date: date)
                            .environmentObject(bottomSettings)
                    }
                    
                }.padding(8)
            }
        }
    }
}
