//
//  CoopRectangularWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 20.09.22.
//

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, macCatalystApplicationExtension 16.0, macCatalyst 16.0, macOS 13.0, *)
struct CoopRectangularWidgetView: View {
    
    let event: CoopEvent
    let date: Date
    var gear: CoopGear?
    var isBackgroundBlurred: Bool = false

    var state: TimeframeActivityState {
        return event.timeframe.state(date: date)
    }
    
    
    var body: some View {
        ZStack{
            if isBackgroundBlurred {
                AccessoryWidgetBackground()
            }
            
            VStack(alignment: .leading, spacing: 2.0) {
                
                HStack(alignment: .center){
                    
                    CoopLogo(event: event).frame(height: 30.0)
                    
                    ColoredActivityTextView(state: state)
                        .scaledSplat2Font(size: 8.0)
                        .padding(.vertical, 2.0)
                        .padding(.horizontal, 4.0)
                    
                    VStack(alignment: .leading){
                    
                        Text(event.stage.name)
                            .scaledSplat2Font(size: 14.0)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.5)

                        RelativeTimeframeView(timeframe: event.timeframe, state: state)
                            .scaledSplat2Font(size: 12.0)
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .minimumScaleFactor(0.5)
                        
                    }.foregroundColor(.primary)

                }.foregroundColor(.primary)

                HStack(alignment: .center) {
                    WeaponsList(weapons: event.weaponDetails)
                        .frame(maxHeight: 24)
                    Spacer()
                    if let gear = gear {
                        GearImage(gear: gear)
                            .frame(minHeight: 16, maxHeight: 24)
                            .shadow(color: .black, radius: 1.0, x: 0.0, y: 0.0)
                            .drawingGroup()
                    }
                }
            }
            .padding(.horizontal, 4.0)
            .padding(.vertical, 2.0)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .widgetAccentable()
    }
}
