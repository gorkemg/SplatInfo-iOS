//
//  SplatInfo+ProjectCommon.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 28.09.22.
//

import Foundation
import SwiftUI

//struct ProjectCommon {
//
//    static let kindSplatoon2ScheduleWidget: String = "Splatoon2ScheduleWidget"
//    static let kindSplatoon3ScheduleWidget: String = "Splatoon3ScheduleWidget"
//
//}

let kindSplatoon2ScheduleWidget: String = "Splatoon2ScheduleWidget"
let kindSplatoon3ScheduleWidget: String = "Splatoon3ScheduleWidget"

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
