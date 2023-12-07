//
//  IconCircularWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 19.09.22.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct IconCircularWidgetView: View {
    
    let startDate: Date
    let endDate: Date
    let imageName: String?
    var isBackgroundBlurred: Bool = true
    var progressTintColor: Color? = nil
    
    var body: some View {
        
        ZStack{
            if isBackgroundBlurred {
                AccessoryWidgetBackground()
            }
            
            ProgressView(timerInterval: startDate...endDate, countsDown: false, label: {

            }, currentValueLabel: {
                if let name = imageName {
                    Image(name).resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .unredacted()
                }
            })
            .progressViewStyle(.circular)
            .tint(progressTintColor)
        }
        .widgetAccentable()
    }
}
