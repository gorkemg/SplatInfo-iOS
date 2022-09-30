//
//  CircularWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 19.09.22.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct CircularWidgetView: View {
    
    let startDate: Date
    let endDate: Date
    let imageName: String?
    
    var body: some View {
        
        ZStack{
            #if TARGET_OS_MACCATALYST
            AccessoryWidgetBackground()
            
            ProgressView(timerInterval: startDate...endDate, countsDown: true, label: {
                
            }, currentValueLabel: {
                if let name = imageName {
                    Image(name).resizable().aspectRatio(contentMode: .fit).frame(width: 20)
                }
            }).progressViewStyle(.circular)
            #endif
        }
    }
}
