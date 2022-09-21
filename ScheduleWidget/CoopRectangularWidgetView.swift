//
//  CoopRectangularWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 20.09.22.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct CoopRectangularWidgetView: View {
    
    let event: CoopEvent
    let date: Date
    
    var state: TimeframeActivityState {
        return event.timeframe.state(date: date)
    }
    
    
    var body: some View {
        ZStack{
            AccessoryWidgetBackground()
            
            HStack(alignment: .center, spacing: 4.0) {
                                
                VStack(alignment: .leading, spacing: 2.0) {
                    
                    HStack(alignment: .center){
                        CoopLogo(event: event).frame(height: 16.0)
                        Text(event.stage.name).scaledSplat2Font(size: 9.0).lineLimit(1)
                    }.foregroundColor(.primary)

                    HStack(alignment: .center){
                        ColoredActivityTextView(state: state).splat2Font(size: 8.0)
                        RelativeTimeframeView(timeframe: event.timeframe, state: state)
                            .scaledSplat2Font(size: 8.0)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }.foregroundColor(.primary)
                    
                    WeaponsList(weapons: event.weaponDetails)
                }
            }
            .padding(.horizontal, 8.0)
            .padding(.vertical, 2.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .widgetAccentable()
    }
}
