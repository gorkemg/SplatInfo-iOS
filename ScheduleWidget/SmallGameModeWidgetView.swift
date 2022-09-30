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

                //event.mode.color

                Image("splatoon-card-bg").resizable(resizingMode: .tile)

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
                
                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom)

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
