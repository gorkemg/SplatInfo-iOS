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
                                Spacer()
                                RelativeTimeframeView(timeframe: event.timeframe, state: event.timeframe.state(date: date))
                                    .splat2Font(size: 12).lineLimit(1).minimumScaleFactor(0.5).multilineTextAlignment(.trailing)
                            }.padding(.horizontal, 2)

                        }
                    }.frame(maxHeight: (geometry.size.height*2/3))
                    
                    if let nextEvent = nextEvent {
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
                            
                        }.frame(maxHeight: (geometry.size.height*1/3))
                    }
                    
                }.padding(8)
                
            }
        }
    }

}
