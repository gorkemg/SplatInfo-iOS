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
        
    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .topLeading) {

                event.mode.color
                event.mode.bgImage

                VStack {

                    GameModeEventView(event: event, style: .large, date: date, isRuleLogoVisible: !event.mode.isTurfWar)
                    
                    ForEach(nextEvents.indices, id: \.self) { i in
                        let nextEvent = nextEvents[i]
                        GameModeEventView(event: nextEvent, style: .threeColumns, date: date)
                    }
                    
                }.padding(8)
            }
        }
    }
}
