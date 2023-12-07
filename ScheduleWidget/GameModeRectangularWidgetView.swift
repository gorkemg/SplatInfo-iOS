//
//  GameModeRectangularWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 20.09.22.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct GameModeRectangularWidgetView: View {
    
    let event: GameModeEvent
    let date: Date
    var isBackgroundBlurred: Bool = false
    
    var state: TimeframeActivityState {
        return event.timeframe.state(date: date)
    }
    
    
    var body: some View {
        ZStack{
            if isBackgroundBlurred {
                AccessoryWidgetBackground()
            }

            HStack(alignment: .center, spacing: 4.0) {
                                
                VStack(alignment: .center, spacing: 1.0){
                    
                    ProgressView(timerInterval: event.timeframe.startDate...event.timeframe.endDate, countsDown: false, label: {
                        
                        HStack(alignment: .center, spacing: 2.0) {
                            if !event.mode.isTurfWar {
                                Image(event.mode.logoName).resizable().aspectRatio(contentMode: .fit).frame(maxHeight: 24)
                            }
                            if case let .splatoon3(type) = event.mode {
                                if case .anarchyBattleOpen = type {
                                    Splatoon3TagView(text: "Open")
                                }else if case .anarchyBattleSeries = type {
                                    Splatoon3TagView(text: "Series")
                                }
                            }
                            Image(event.rule.logoName).resizable().aspectRatio(contentMode: .fit).frame(maxHeight: 20)
                            Spacer()
                        }

                    }) {
                        RelativeTimeframeView(timeframe: event.timeframe, state: state)
                            .scaledSplat2Font(size: 12.0)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                    }
                    .tint(event.mode.color)
                    
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(.primary)//.background(Color.yellow)//.frame(minWidth: 30.0)

                VStack(alignment: .center, spacing: 1.0) {
                    
                    Text(event.stageA?.name ?? "").scaledSplat2Font(size: 9.0)
                        .minimumScaleFactor(0.5)
                        .lineSpacing(0.5)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    Divider()
                    Text(event.stageB?.name ?? "").scaledSplat2Font(size: 9.0)
                        .minimumScaleFactor(0.5)
                        .lineSpacing(0.5)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .foregroundColor(.primary)//.background(Color.red)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.horizontal, 4.0)
            .padding(.vertical, 2.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .widgetBackground(backgroundView: event.mode.color.opacity(0.2))
        .widgetAccentable()
    }
}
