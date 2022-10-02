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

        ViewThatFits {

            HStack{
                Image(event.logoNameSmall).resizable().aspectRatio(contentMode: .fit).frame(width: 12, height: 12)
                Text(event.stage.name)
                RelativeTimeframeView(timeframe: event.timeframe, state: state)
            }

            HStack{
                Text(event.stage.name)
                RelativeTimeframeView(timeframe: event.timeframe, state: state)
            }

            HStack{
                RelativeTimeframeView(timeframe: event.timeframe, state: state)
            }
        }
    }
}
