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
        Text(timeframeString)
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
