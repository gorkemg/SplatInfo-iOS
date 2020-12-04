//
//  TimeframeView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

//struct AdaptiveTimeframeView: View {
//    let timeframe: EventTimeframe
//    var datesEnabled: Bool = false
//    var fontSize: CGFloat = 14
//    let date: Date
//
//    var body: some View {
//        switch timeframe.state(date: date) {
//        case active:
//            RelativeTimeframeView(timeframe: timeframe, date: date)
//        default:
//            TimeframeView(timeframe: timeframe, datesEnabled: datesEnabled, fontSize: fontSize)
//        }
//    }
//}

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
    let state: TimeframeActivityState
    
    var formatter : Formatter {
        if state == .active {
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
        Text(relativeDate, style: .relative)
            //.shadow(color: .black, radius: 1, x: 0, y: 1)
        //.splat2Font(size: 12)
        //Text(date, formatter: formatter)
            //.splat2Font(size: 12)
    }
    
    var relativeDate : Date {
        return state == .active ? timeframe.endDate : timeframe.startDate
    }
    
}


struct ActivityTimeFrameView : View {
    let timeframe: EventTimeframe
    let state: TimeframeActivityState

    var body: some View {
        switch state {
        case .active:
            Text("- \(timeframeEndString)").splat2Font(size: 10)
        case .soon:
            Text("\(timeframeStartString) - \(timeframeEndString)").splat2Font(size: 10)
        case .over:
            Text("- \(timeframeEndString)").splat2Font(size: 10)
        }
    }
    var timeframeStartString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: timeframe.startDate)
    }
    var timeframeEndString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        return formatter.string(from: timeframe.endDate)
    }

}

extension TimeframeActivityState {
    var activityText: String {
        switch self {
        case .active:
            return "Open!"
        case .soon:
            return "Soon!"
        case .over:
            return "Ended!"
        }
    }
}
