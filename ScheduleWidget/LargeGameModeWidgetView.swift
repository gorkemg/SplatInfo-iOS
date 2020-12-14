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

                event.mode.type.color

                Image("splatoon-card-bg").resizable(resizingMode: .tile)

                VStack(alignment: .center, spacing: 8) {
                    
                    VStack(alignment: .center, spacing: 8) {
                        
                        HStack(alignment: .center) {
                            HStack(alignment: .center, spacing: 4.0) {
                                Image(event.mode.type.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 24)
                                Text(event.rule.name).minimumScaleFactor(0.5)
                            }.splat2Font(size: 20)
                            Spacer()
                            RelativeTimeframeView(timeframe: event.timeframe, state: event.timeframe.state(date: date)).multilineTextAlignment(.trailing).splat2Font(size: 14)
                        }.padding(.horizontal, 2)
                        
                        LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
                            if let stage = event.stageA {
                                StageImage(stage: stage, height: 100)
                            }
                            if let stage = event.stageB {
                                StageImage(stage: stage, height: 100)
                            }
                        }

                    }.padding(8).background(Color.black.opacity(0.4)).cornerRadius(10.0)

                    VStack(alignment: .center, spacing: 8) {

                        ForEach(nextEvents.indices, id: \.self) { i in
                            let next = nextEvents[i]
                            //let state = event.timeframe.state(date: date)

                            HStack {
                                
                                VStack(spacing: 0.0) {
                                    Text(next.rule.name).splat2Font(size: 12).minimumScaleFactor(0.5)
                                    TimeframeView(timeframe: next.timeframe, datesStyle: .never, fontSize: 9).lineLimit(2).minimumScaleFactor(0.5).multilineTextAlignment(.center)
                                }.frame(minWidth: 80)

                                if let stage = next.stageA {
                                    StageImage(stage: stage, height: 50)
                                }

                                if let stage = next.stageB {
                                    StageImage(stage: stage, height: 50)
                                }
                            }

                        }

                    }
                    
                }.padding(8)
                
            }
        }
    }

    func relativeTimeText(event: GameModeEvent) -> Text {
        switch event.timeframe.state(date: date) {
        case .active:
            return Text(" since ") + Text(event.timeframe.startDate, style: .relative)
        case .soon:
            return Text(" in ") + Text(event.timeframe.startDate, style: .relative)
        case .over:
            return Text(" ended ") + Text(event.timeframe.endDate, style: .relative) + Text(" ago")
        }
    }
}
