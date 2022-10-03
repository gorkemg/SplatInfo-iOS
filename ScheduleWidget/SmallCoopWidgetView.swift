//
//  SmallCoopWidgetView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 31.10.20.
//

import SwiftUI

struct SmallCoopWidgetView : View {
    let event: CoopEvent
    let state: TimeframeActivityState

    var body: some View {
        CoopEventView(event: event, style: .topBottom, state: state)
    }
}
