//
//  CoopInlineWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 20.09.22.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct CoopInlineWidgetView: View {
    
    let event: CoopEvent
    let date: Date
    
    var state: TimeframeActivityState {
        return event.timeframe.state(date: date)
    }
    
    
    var body: some View {
        
        RelativeTimeframeView(timeframe: event.timeframe, state: state)
        
        //Text(event.timeframe.dateForState(state: state), style: .relative)//.splat2Font(size: 10)
        //+ Text(event.stage.name)

//        ZStack{
//            AccessoryWidgetBackground()
//            HStack(alignment: .center, spacing: 4.0) {
//
//                //Image(event.logoNameSmall)//.resizable().aspectRatio(contentMode: .fit).frame(width: 20)
//
//                Text(event.stage.name).splat2Font(size: 10).lineLimit(1)
//
////                ColoredActivityTextView(state: state).splat2Font(size: 8.0)
////                RelativeTimeframeView(timeframe: event.timeframe, state: state)
////                    .splat2Font(size: 10)
////                    .lineLimit(1)
////                    .minimumScaleFactor(0.5)
//
//            }.padding(2.0).widgetAccentable()
//        }
    }
}
