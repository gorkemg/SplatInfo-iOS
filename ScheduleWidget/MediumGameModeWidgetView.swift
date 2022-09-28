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
                                    PillStageImage(stage: stage, height: innerGeo.size.height)
                                }
                                if let stage = event.stageB {
                                    PillStageImage(stage: stage, height: innerGeo.size.height)
                                }
                            }
                            
                            HStack(alignment: .top) {
                                GameModeEventTitleView(event: event, gameLogoPosition: .trailing)
                                Spacer()
                                HStack{
                                    let state = event.timeframe.state(date: date)
                                    RelativeTimeframeView(timeframe: event.timeframe, state: state)
                                        .splat2Font(size: 12).lineLimit(1).minimumScaleFactor(0.5).multilineTextAlignment(.trailing)
                                    ColoredActivityTextView(state: state)
                                        .splat2Font(size: 12)
                                }
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
                                    PillStageImage(stage: stage, height: innerGeo.size.height)
                                }

                                if let stage = nextEvent.stageB {
                                    PillStageImage(stage: stage, height: innerGeo.size.height)
                                }
                            }
                            
                        }.frame(maxHeight: (geometry.size.height*1/3))
                    }
                    
                }.padding(8)
                
            }
        }
    }

}
