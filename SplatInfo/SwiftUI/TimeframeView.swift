//
//  TimeframeView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct TimeframeView: View {
    let timeframe: EventTimeframe
    var datesEnabled: Bool = false

    var body: some View {
        Text(timeframeString).splat2Font(size: 14)
    }

    var timeframeString : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = datesEnabled ? .short : .none
        dateFormatter.timeStyle = .short
        let startString = dateFormatter.string(from: timeframe.startDate)
        let endString = dateFormatter.string(from: timeframe.endDate)
        return "\(startString) - \(endString)"
    }
}

struct RelativeTimeframeView : View {
    
    let timeframe : EventTimeframe
    
    let timer = Timer.publish(
        every: 1, // second
        on: .main,
        in: .common
    ).autoconnect()

    @State var relativeTimeString: String = ""

    var body: some View {
        Text(relativeTimeString).onReceive(timer) { (_) in
            self.relativeTimeString = timeframe.isActive ? timeframe.endDate.relativeTimeRemaining() : timeframe.startDate.relativeTimeAhead()
        }
        .splat2Font(size: 12)
    }
}
