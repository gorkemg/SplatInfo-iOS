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
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack(alignment: .topLeading) {

                event.mode.color
                event.mode.bgImage

                VStack(spacing: 8.0) {
                    
                    GameModeEventView(event: event, style: .large, date: date, isRuleLogoVisible: !event.mode.isTurfWar)
                    
                    if let nextEvent = nextEvent {
                        GameModeEventView(event: nextEvent, style: .threeColumns, date: date)
                    }
                    
                }.padding(8)
                
            }
        }
    }

}
