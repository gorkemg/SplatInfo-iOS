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
            HStack(alignment: .center, spacing: 4.0) {
                                
                VStack(alignment: .leading, spacing: 2.0) {
                    
                    HStack(alignment: .center){
                        CoopLogo(event: event)
                        Text(event.stage.name).scaledSplat2Font(size: 10).lineLimit(1)
                    }

                    HStack(alignment: .center){
                        ColoredActivityTextView(state: state).splat2Font(size: 8.0)
                        RelativeTimeframeView(timeframe: event.timeframe, state: state)
                            .scaledSplat2Font(size: 10)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    
                    WeaponsList(weapons: event.weaponDetails)
                }
            }.padding(2.0)
        }.widgetAccentable(true)
    }
}
