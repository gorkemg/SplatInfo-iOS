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
    var datesStyle: DateStyle = .adaptive
    var fontSize: CGFloat = 14

    enum DateStyle {
        case always
        case adaptive
        case never
    }
    
    var body: some View {
        Text(timeframeString).splat2Font(size: fontSize)
    }

    var timeframeString : String {
        if datesStyle == .never {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            return "\(dateFormatter.string(from: timeframe.startDate)) - \(dateFormatter.string(from: timeframe.endDate))"
        }
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = datesStyle == .always ? .short : .none
        formatter.timeStyle = .short
        return formatter.string(from: timeframe.startDate, to: timeframe.endDate)
    }
}

struct RelativeTimeframeView : View {
    
    let timeframe : EventTimeframe
    let state: TimeframeActivityState
            
    var body: some View {
        //Text(timeframe.dateForState(state: state), style: .relative)
        timeframe.relativeTimeText(state: state)
    }
}

extension EventTimeframe {
    
    func dateForState(state: TimeframeActivityState) -> Date {
        switch state {
        case .active:
            return endDate
        case .soon:
            return startDate
        case .over:
            return endDate
        }
    }
}

struct ActivityTimeFrameView : View {
    let timeframe: EventTimeframe
    let state: TimeframeActivityState
    var fontSize: CGFloat = 10

    var body: some View {
        switch state {
        case .active:
            Text("- \(timeframeEndString)").splat2Font(size: fontSize)
        case .soon:
            Text("\(timeframeStartString) - \(timeframeEndString)").splat2Font(size: fontSize)
        case .over:
            Text("- \(timeframeEndString)").splat2Font(size: fontSize)
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
            return "Now!"
        case .soon:
            return "Soon!"
        case .over:
            return "Ended!"
        }
    }
}
