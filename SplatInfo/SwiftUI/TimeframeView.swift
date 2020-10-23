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
    var fontSize: CGFloat = 14

    var body: some View {
        Text(timeframeString).splat2Font(size: fontSize)
    }

    var timeframeString : String {
        
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = datesEnabled ? .short : .none
        formatter.timeStyle = .short
        return formatter.string(from: timeframe.startDate, to: timeframe.endDate)
    }
}

struct RelativeTimeframeView : View {
    
    let timeframe : EventTimeframe
    
    var formatter : Formatter {
        if timeframe.isActive {
            let formatter = RelativeDateTimeFormatter()
            formatter.dateTimeStyle = .numeric
            formatter.unitsStyle = .abbreviated
            return formatter
        }else{
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.doesRelativeDateFormatting = true
            return formatter
        }
    }
        
    var body: some View {
        // ** CRASH when using custom fonts or shadow **
        Text(date, style: .relative)
            //.shadow(color: .black, radius: 1, x: 0, y: 1)
        //.splat2Font(size: 12)
        //Text(date, formatter: formatter)
            //.splat2Font(size: 12)
    }
    
    var date : Date {
        return timeframe.isActive ? timeframe.endDate : timeframe.startDate
    }
    
}
