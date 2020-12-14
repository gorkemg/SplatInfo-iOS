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
    
    var isTitleVisible: Bool = true
    var isRuleNameVisible: Bool = true

    enum Style {
        case large
        case medium
        case narrow
    }
    
    var isTurfWar : Bool {
        return gameModeEvent.mode.type == .regular
    }
    
    var body: some View {
        VStack {
            switch style {
            case .large:
                VStack {
                    VStack (spacing: 10) {
                        HStack {
                            if isRuleNameVisible {
                                Text(gameModeEvent.rule.name)
                                    .splat2Font(size: 22)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
//                                RelativeTimeframeView(timeframe: gameModeEvent.timeframe, state: gameModeEvent.timeframe.state(date: date))
//                                    .splat2Font(size: 14)
//                                    .lineLimit(1)
//                                    .minimumScaleFactor(0.5)
//                                    .multilineTextAlignment(.trailing)
                                TimeframeView(timeframe: gameModeEvent.timeframe)
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
                }//.background(Color.red)
                
            case .medium:
                VStack(spacing: 0.0) {
                    if isTitleVisible {
                        HStack(alignment: .center, spacing: 0.0) {
                            Text(gameModeEvent.rule.name)
                                .splat2Font(size: 16)
                            Spacer()
                            RelativeTimeframeView(timeframe: gameModeEvent.timeframe, state: gameModeEvent.timeframe.state(date: date))
                                .splat2Font(size: 12)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())]) {
                        VStack(alignment: .center, spacing: 0.0) {
                            if !isTitleVisible {
                                if isRuleNameVisible {
                                    Text(gameModeEvent.rule.name).lineLimit(1).minimumScaleFactor(0.5)
                                        .splat2Font(size: 14).multilineTextAlignment(.center)
                                }
                            }
                            TimeframeView(timeframe: gameModeEvent.timeframe, fontSize: 12)
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                        }
                        Group {
                            if let stage = gameModeEvent.stageA {
                                StageImage(stage: stage, height: 50)
                            }
                        }
                        Group {
                            if let stage = gameModeEvent.stageB {
                                StageImage(stage: stage, height: 50)
                            }
                        }
                    }
                }//.background(Color.blue)
               
            case .narrow:
                VStack(spacing: 0.0) {
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
                        Group {
                            if let stage = gameModeEvent.stageA {
                                StageImage(stage: stage)
                            }
                        }
                        Group {
                            if let stage = gameModeEvent.stageB {
                                StageImage(stage: stage)
                            }
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
