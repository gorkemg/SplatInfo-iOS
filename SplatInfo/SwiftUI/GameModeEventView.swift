//
//  GameModeEventView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct GameModeEventView: View {
    let event: GameModeEvent
    let style: Style
    var date: Date = Date()
    
    var isTitleVisible: Bool = true
    var isRuleLogoVisible: Bool = true
    var isRuleNameVisible: Bool = true

    enum Style {
        case large
        case medium
        case narrow
    }
    
    var isTurfWar : Bool {
        return event.mode.type == .regular
    }
    
    var body: some View {
        VStack {
            switch style {
            case .large:
                GeometryReader { innerGeo in
                    
                    ZStack(alignment: .topLeading) {
                        
                        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
                            if let stage = event.stageA {
                                StageImage(stage: stage, height: innerGeo.size.height)
                            }
                            if let stage = event.stageB {
                                StageImage(stage: stage, height: innerGeo.size.height)
                            }
                        }
                        
                        HStack(alignment: .center) {
                            HStack(alignment: .center, spacing: 2.0) {
                                if isTitleVisible {
                                    if isRuleLogoVisible {
                                        Image(event.mode.type.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 24).shadow(color: .black, radius: 1, x: 0, y: 1)
                                    }
                                    if isRuleNameVisible {
                                        Text(event.rule.name).splat2Font(size: 16).minimumScaleFactor(0.5)
                                    }
                                }
                            }
                            Spacer()
                            RelativeTimeframeView(timeframe: event.timeframe, state: event.timeframe.state(date: date))
                                .splat2Font(size: 12).lineLimit(1).minimumScaleFactor(0.5).multilineTextAlignment(.trailing)
                        }.padding(.horizontal, 2)

                    }
                }.frame(minHeight: 100, idealHeight: 120)

            case .medium:
                GeometryReader { innerGeo in
                    
                    HStack(alignment: .center) {
                        
                        VStack(spacing: 0.0) {
                            Text(event.rule.name).splat2Font(size: 14).minimumScaleFactor(0.5)
                            TimeframeView(timeframe: event.timeframe, datesStyle: .never, fontSize: 10)
                                .lineLimit(2).minimumScaleFactor(0.5).multilineTextAlignment(.center)
                        }.frame(minWidth: min(80,innerGeo.size.width/3), maxWidth: innerGeo.size.width/3)

                        if let stage = event.stageA {
                            StageImage(stage: stage, height: innerGeo.size.height)
                        }

                        if let stage = event.stageB {
                            StageImage(stage: stage, height: innerGeo.size.height)
                        }
                    }
                    
                }.frame(minHeight: 50, idealHeight: 60)

            case .narrow:
                GeometryReader { innerGeo in
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
                        Group {
                            if let stage = event.stageA {
                                StageImage(stage: stage)
                            }
                        }
                        Group {
                            if let stage = event.stageB {
                                StageImage(stage: stage)
                            }
                        }
                    }
                }.background(Color.blue)
                
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
