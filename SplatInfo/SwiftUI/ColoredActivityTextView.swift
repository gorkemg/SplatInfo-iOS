//
//  ColoredActivityTextView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 15.10.22.
//

import SwiftUI
import WidgetKit

struct ColoredActivityTextView: View {
    let state: TimeframeActivityState

#if os(watchOS)
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
#endif

    var body: some View {
        HStack {
            Text(state.activityText)
                #if os(watchOS)
                .if(widgetRenderingMode != .accented, transform: { view in
                    view
                        .shadow(color: .black, radius: 1.0, x: 0.0, y: 1.0)
                        .drawingGroup()
                })
                #else
                    .shadow(color: .black, radius: 1.0, x: 0.0, y: 1.0)
                    .drawingGroup()

                #endif
        }
        .padding(.horizontal, 4.0)
        #if os(watchOS)
        .if(widgetRenderingMode != .accented, transform: { view in
            view
                .background(state.color).cornerRadius(5.0)
        })
        #else
            .background(state.color).cornerRadius(5.0)
            .shadow(color: .black, radius: 1.0, x: 0.0, y: 1.0)
            .drawingGroup()
        #endif
    }
}
