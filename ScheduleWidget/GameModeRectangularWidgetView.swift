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
    
    let event: Splatoon2.GameModeEvent
    let date: Date
    
    var state: TimeframeActivityState {
        return event.timeframe.state(date: date)
    }
    
    
    var body: some View {
        ZStack{
            AccessoryWidgetBackground()
            
            HStack(alignment: .center, spacing: 4.0) {
                                
                VStack(alignment: .center, spacing: 1.0){
                    Image(event.mode.type.logoNameSmall).resizable().aspectRatio(contentMode: .fit).frame(height: 20).shadow(color: .black, radius: 1, x: 0.0, y: 1.0)

                    Text(event.rule.name).scaledSplat2Font(size: 12)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)

                    RelativeTimeframeView(timeframe: event.timeframe, state: state)
                        .scaledSplat2Font(size: 12.0)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        
                    
                }.foregroundColor(.primary)//.background(Color.yellow)//.frame(minWidth: 30.0)

                VStack(alignment: .center, spacing: 1.0) {
                    
                    Text(event.stageA?.name ?? "").scaledSplat2Font(size: 9.0)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    Text(event.stageB?.name ?? "").scaledSplat2Font(size: 9.0)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }.foregroundColor(.primary)//.background(Color.red)
            }
            .padding(.horizontal, 4.0)
            .padding(.vertical, 2.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .widgetAccentable()
    }
}
