//
//  GameModeInlineWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 21.09.22.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct GameModeInlineWidgetView: View {
    
    let event: Splatoon2.GameModeEvent
    let date: Date
    
    var state: TimeframeActivityState {
        return event.timeframe.state(date: date)
    }
    
    
    var body: some View {
        
        ViewThatFits(in: .horizontal) {
//            HStack(spacing: 2.0) {
////                Image(event.mode.type.logoName).resizable().aspectRatio(contentMode: .fit).frame(height: 14)
//                RelativeTimeframeView(timeframe: event.timeframe, state: state).minimumScaleFactor(0.5)
//            }.widgetAccentable()

            HStack {
                Image(event.mode.type.logoNameSmall)//.resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 14, maxHeight: 14)
                Text(event.rule.name) + Text(" • ") + Text(event.timeframe.dateForState(state: state), style: .relative)
            }.scaledSplat2Font(size: 10)
                .minimumScaleFactor(0.5)
            
            Text("Das ist ein sehr langer Text, mal sehen wie viel ")

            Text("Das ist ein sehr langer Text")

            Text("Das ist ein")

        }.widgetAccentable()

        //Text(event.timeframe.dateForState(state: state), style: .relative)//.splat2Font(size: 10)
        //+ Text(event.stage.name)

//        ZStack{
//            AccessoryWidgetBackground()
//            HStack(alignment: .center, spacing: 4.0) {
//
//                //Image(event.logoName)//.resizable().aspectRatio(contentMode: .fit).frame(width: 20)
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
