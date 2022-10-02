//
//  SmallGameModeWidgetView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 31.10.20.
//

import SwiftUI

struct SmallGameModeWidgetView : View {
    let event: GameModeEvent
    var nextEvent: GameModeEvent? = nil
    let date: Date

    var body: some View {
        ZStack(alignment: .topTrailing){
            
            ZStack(alignment: .topLeading) {

                event.mode.color
                event.mode.bgImage

                GeometryReader { geometry in
                    VStack(spacing: 0.0) {
                        VStack(spacing: 0) {
                            if let stage = event.stageA {
                                StageImage(stage: stage, namePosition: .bottom, height: geometry.size.height)
                            }
                            if let stage = event.stageB {
                                StageImage(stage: stage, namePosition: .top, height: geometry.size.height)
                            }
                        }
                    }.cornerRadius(10.0)
                }
                
                VStack(alignment: .leading, spacing: 0.0) {
                    
                    VStack(alignment: .leading, spacing: 0.0) {
                        GameModeEventTitleView(event: event, gameLogoPosition: .trailing, isRuleLogoVisible: !event.mode.isTurfWar)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 0.0) {
                        if let next = nextEvent {
                            Text(!event.mode.isTurfWar ? next.rule.name : "Changes")
                                + next.timeframe.relativeTimeText(date: date)
                        }
                    }.splat2Font(size: 10).lineLimit(1).minimumScaleFactor(0.5)
                }.padding(.horizontal, 10.0).padding(.vertical, 8.0)
            }

        }
    }
}
