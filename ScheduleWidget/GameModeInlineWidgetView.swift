//
//  GameModeInlineWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 21.09.22.
//

import SwiftUI
import WidgetKit

@available(iOS 16.0, iOSApplicationExtension 16.0, macCatalystApplicationExtension 16.0, *)
struct GameModeInlineWidgetView: View {
    
    let event: GameModeEvent
    let date: Date
    
    var state: TimeframeActivityState {
        return event.timeframe.state(date: date)
    }
    
    
    var body: some View {
        
        ViewThatFits(in: .horizontal) {

            HStack(spacing: 2.0) {
                Image(event.mode.logoNameSmall).resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 14, maxHeight: 14)
                Text(event.rule.name) + Text(" • ") + Text(event.timeframe.dateForState(state: state), style: .relative)
            }
            .scaledSplat2Font(size: 10)
            .minimumScaleFactor(0.5)

            HStack(spacing: 2.0) {
                Image(event.mode.logoNameSmall)//.resizable().aspectRatio(contentMode: .fit).frame(maxWidth: 14, maxHeight: 14)
                Text(event.rule.name)
            }
            .scaledSplat2Font(size: 10)
            .minimumScaleFactor(0.5)

        }.widgetAccentable()

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
