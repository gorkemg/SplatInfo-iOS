//
//  CoopCircularWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 19.09.22.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
struct CoopCircularWidgetView: View {
    
    let event: CoopEvent
    var isBackgroundBlurred: Bool = true
    
    var body: some View {
        
        ZStack{
            if isBackgroundBlurred {
                AccessoryWidgetBackground()
            }
            
            ProgressView(timerInterval: event.timeframe.startDate...event.timeframe.endDate, countsDown: true, label: {

            }, currentValueLabel: {
                VStack(alignment: .center, spacing: 0.0){
                    HStack(alignment: .bottom, spacing: 0.0) {
                        if let weapon = event.weaponDetails.first {
                            WeaponImage(weapon: weapon).frame(minWidth: 20, minHeight: 20)
                        }
                        if let weapon = event.weaponDetails.second {
                            WeaponImage(weapon: weapon).frame(minWidth: 20, minHeight: 20)
                        }
                    }
                    HStack(alignment: .top, spacing: 0.0) {
                        if let weapon = event.weaponDetails.third {
                            WeaponImage(weapon: weapon).frame(minWidth: 20, minHeight: 20)
                        }
                        if let weapon = event.weaponDetails.fourth {
                            WeaponImage(weapon: weapon).frame(minWidth: 20, minHeight: 20)
                        }
                    }
                }
            }).progressViewStyle(.circular)
        }
    }
}
