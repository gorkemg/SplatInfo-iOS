//
//  MediumCoopWidgetView.swift
//  SplatInfoScheduleWidgetExtension
//
//  Created by Görkem Güclü on 14.12.20.
//

import SwiftUI

struct MediumCoopWidgetView : View {
    let event: CoopEvent
    let nextEvent: CoopEvent?
    let date: Date

    var state: TimeframeActivityState {
        return event.timeframe.state(date: date)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {

            Color.coopModeColor

            Image("bg-spots").resizable(resizingMode: .tile)
                        
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.05), Color.black.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 2.0) {

                GeometryReader { geometry in

                    VStack(alignment: .leading, spacing: 8) {

                        ZStack(alignment: .topLeading) {
                            
                            if let image = event.stage.image {
                                Image(uiImage: image).centerCropped()
                                    .cornerRadius(10.0)
                            }

                            VStack(alignment: .leading, spacing: 0.0) {
                                HStack(alignment: .center) {
                                    HStack(alignment: .center) {
                                        Image(event.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 20).shadow(color: .black, radius: 1, x: 0, y: 1)
                                        Text(event.modeName).splat2Font(size: 14).minimumScaleFactor(0.5).lineSpacing(0)
                                        ColoredActivityTextView(state: state).splat2Font(size: 10)
                                    }
                                    Spacer()
                                    RelativeTimeframeView(timeframe: event.timeframe, state: state)
                                        .splat2Font(size: 10)
                                        .multilineTextAlignment(.trailing)
                                        .padding(0.0)
                                }
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading, spacing: 0.0) {
                                        Text(event.stage.name)
                                            .splat2Font(size: 10)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(1)
                                        ActivityTimeFrameView(timeframe: event.timeframe, state: state, fontSize: 8).lineLimit(1).minimumScaleFactor(0.5)
                                    }
                                    .multilineTextAlignment(.leading)

                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("Available Weapons").splat1Font(size: 9)
                                        WeaponsList(weapons: event.weaponDetails)
                                            .shadow(color: .black, radius: 2, x: 0, y: 1)
                                            .frame(minHeight: 20, maxHeight: 30, alignment: .leading)
                                    }.padding(2)
                                }
                                .padding(0.0)
                                
                            }.padding([.leading, .bottom, .trailing], 4)
                        }

                        if let nextEvent = nextEvent {
                            let state = nextEvent.timeframe.state(date: date)
                            CoopNarrowEventView(event: nextEvent, state: state)
                        }

                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                    
                }.padding(2)
            }
            .padding(.horizontal, 10.0).padding(.vertical, 4.0)

        }.foregroundColor(.white)
    }
}
