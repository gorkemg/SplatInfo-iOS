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
    let date: Date
        
    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: .topLeading) {

                //event.mode.color

                Image("splatoon-card-bg").resizable(resizingMode: .tile)

                VStack {
                    GeometryReader { innerGeo in
                        
                        ZStack(alignment: .topLeading) {
                            
                            HStack {
                                if let stage = event.stageA {
                                    StageImage(stage: stage, height: innerGeo.size.height)
                                }
                                if let stage = event.stageB {
                                    StageImage(stage: stage, height: innerGeo.size.height)
                                }
                            }
                            
                            HStack(alignment: .top) {
                                GameModeEventTitleView(event: event)
//                                HStack(alignment: .center, spacing: 2.0) {
//                                    Image(event.mode.type.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 24).shadow(color: .black, radius: 1, x: 0.0, y: 1.0)
//                                    Text(event.rule.name).splat2Font(size: 16).minimumScaleFactor(0.5)
//                                }
                                Spacer()
                                RelativeTimeframeView(timeframe: event.timeframe, state: event.timeframe.state(date: date))
                                    .splat2Font(size: 12).lineLimit(1).minimumScaleFactor(0.5).multilineTextAlignment(.trailing)

                            }.padding(.horizontal, 2)

                        }
                    }.frame(minHeight: 100, idealHeight: 120)
                    
                    ForEach(nextEvents.indices, id: \.self) { i in
                        let nextEvent = nextEvents[i]
                        GeometryReader { innerGeo in

                            HStack(alignment: .center) {
                                
                                VStack(spacing: 0.0) {
                                    Text(nextEvent.rule.name).splat2Font(size: 12).minimumScaleFactor(0.5)
                                    TimeframeView(timeframe: nextEvent.timeframe, datesStyle: .never, fontSize: 9)
                                        .lineLimit(2).minimumScaleFactor(0.5).multilineTextAlignment(.center)
                                }.frame(width: innerGeo.size.width/3)

                                if let stage = nextEvent.stageA {
                                    StageImage(stage: stage, height: innerGeo.size.height)
                                }

                                if let stage = nextEvent.stageB {
                                    StageImage(stage: stage, height: innerGeo.size.height)
                                }
                            }
                            
                        }
                    }
                    
                }.padding(8)
                
            }
        }
    }
}
