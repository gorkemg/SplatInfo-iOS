//
//  GameModeEventView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct GameModeEventView: View {
    let gameModeEvent: GameModeEvent
    let style: Style
    var date: Date = Date()
    
    enum Style {
        case large
        case narrow
    }
    
    var body: some View {
        VStack {
            switch style {
            case .large:
                VStack {
                    VStack (spacing: 10) {
                        HStack {
                            Text(gameModeEvent.rule.name)
                                .splat2Font(size: 22)
                            Spacer()
                            VStack(alignment: .trailing) {
                                TimeframeView(timeframe: gameModeEvent.timeframe)
                                RelativeTimeframeView(timeframe: gameModeEvent.timeframe, state: gameModeEvent.timeframe.state(date: date))
                                    .splat2Font(size: 12)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
                            if let stage = gameModeEvent.stageA {
                                StageImage(stage: stage)
                            }
                            if let stage = gameModeEvent.stageB {
                                StageImage(stage: stage)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                }
            case .narrow:
                VStack {
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]) {
                        VStack(alignment: .center, spacing: 0.0) {
                            Text(gameModeEvent.rule.name)
                                .splat2Font(size: 16)
                            
                            RelativeTimeframeView(timeframe: gameModeEvent.timeframe, state: gameModeEvent.timeframe.state(date: date))
                                .splat2Font(size: 12)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            
                            TimeframeView(timeframe: gameModeEvent.timeframe)
                                .splat2Font(size: 12)
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                        }
                        if let stage = gameModeEvent.stageA {
                            StageImage(stage: stage)
                        }
                        if let stage = gameModeEvent.stageB {
                            StageImage(stage: stage)
                        }
                    }
                }
            }
        }
    }

}

extension GameModeEvent {
    var stageA : Stage? {
        return stages.first
    }
    var stageB : Stage? {
        return stages.last
    }
}
