//
//  TimelineCard.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct Splatoon2TimelineCard: View {
    
    let timeline : Splatoon2.TimelineType
    var numberOfEventsDisplayed: Int = 4
    @State private var showingSheet = false
    @EnvironmentObject var eventViewSettings: EventViewSettings

    var body: some View {

        ZStack(alignment: .top) {
            ContainerRelativeShape()
                            .inset(by: 4)

            switch timeline {
            case .game(let mode, let timeline):

                mode.color
                mode.bgImage

                VStack(alignment: .center, spacing: 8.0) {

                    TitleView(title: mode.name, logoName: mode.logoName)
                    GameModeTimelineView(mode: .splatoon2(type: mode), events: Array(timeline.events.prefix(numberOfEventsDisplayed)))

                    Spacer()
                    if timeline.events.count > numberOfEventsDisplayed {
                        Button {
                            showingSheet.toggle()
                        } label: {
                            Text("More Events")
                        }
                        .padding(.vertical, 4.0)
                        .padding(.horizontal, 12.0)
                        .background(.white.opacity(0.3))
                        .cornerRadius(10)
                        .splat1Font(size: 18)
                        .sheet(isPresented: $showingSheet) {
                            Splatoon2TimelineSheetView(timeline: self.timeline)
                                .clearModalBackground()
                                .environmentObject(eventViewSettings)
                        }
                    }

                }
                .frame(minHeight: 450, maxHeight: .infinity, alignment: .top)
                .padding()

            case .coop(let timeline):

                let mode = Splatoon2.GameModeType.salmonRun
                mode.color
                mode.bgImage
                
                VStack(alignment: .center, spacing: 8.0) {

                    TitleView(title: mode.name, logoName: mode.logoName)
                    CoopTimelineView(coopTimeline: timeline)

                    Spacer()
                    
                    if timeline.events.count > numberOfEventsDisplayed {
                        Button {
                            showingSheet.toggle()
                        } label: {
                            Text("More Events")
                        }
                        .padding(.vertical, 4.0)
                        .padding(.horizontal, 12.0)
                        .background(.white.opacity(0.3))
                        .cornerRadius(10)
                        .splat1Font(size: 18)
                        .sheet(isPresented: $showingSheet) {
                            Splatoon2TimelineSheetView(timeline: self.timeline)
                                .clearModalBackground()
                                .environmentObject(eventViewSettings)

                        }
                    }
                }
                .frame(minHeight: 450, maxHeight: .infinity, alignment: .top)
                .padding()

            }
        }
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
        .splat2Font(size: 12)
    }
}

struct Splatoon2TimelineSheetView: View {
    
    let timeline : Splatoon2.TimelineType

    var body: some View {
        ScrollView(.vertical) {
            Splatoon2TimelineCard(timeline: self.timeline, numberOfEventsDisplayed: self.timeline.events.count)
                .frame(minHeight: CGFloat(self.timeline.events.count) * 80.0)
        }
    }
}

struct Splatoon3TimelineCard: View {

    let timeline : Splatoon3.TimelineType
    var numberOfEventsDisplayed: Int = 4
    @State private var showingSheet = false
    @EnvironmentObject var eventViewSettings: EventViewSettings

    var body: some View {

        ZStack(alignment: .top) {
            ContainerRelativeShape()
                            .inset(by: 4)

            switch timeline {
            case .game(let mode, let timeline):

                mode.color
                mode.bgImage

                VStack(alignment: .center, spacing: 8.0) {

                    if case .splatfest(let fest) = mode {
                        if let image = SplatfestIcon.iconForSplatfest(fest) {
                            TitleView(title: mode.name, uiImage: image)
                        }else{
                            TitleView(title: mode.name, logoName: mode.logoName)
                        }
                        Text(fest.title)
                            .splat2Font(size: 18)
                            .lineLimit(2)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                    }else{
                        TitleView(title: mode.name, logoName: mode.logoName)
                    }
                    ScrollView(.vertical) {
                        GameModeTimelineView(mode: .splatoon3(type: mode), events: Array(timeline.events.prefix(numberOfEventsDisplayed)))
                            .frame(minHeight: CGFloat(numberOfEventsDisplayed) * 80.0, alignment: .center)
                            .padding(4.0)
                    }
                    Spacer()
                    if timeline.events.count > numberOfEventsDisplayed {
                        Button {
                            showingSheet.toggle()
                        } label: {
                            Text("More Events")
                        }
                        .padding(.vertical, 4.0)
                        .padding(.horizontal, 12.0)
                        .background(.white.opacity(0.3))
                        .cornerRadius(10)
                        .splat1Font(size: 18)
                        .sheet(isPresented: $showingSheet) {
                            Splatoon3TimelineSheetView(timeline: self.timeline)
                                .clearModalBackground()
                                .environmentObject(eventViewSettings)

                        }
                    }
                }
                .frame(minHeight: 450, maxHeight: .infinity, alignment: .top)
                .padding()

            case .coop(let timeline):

                let mode = Splatoon2.GameModeType.salmonRun
                mode.color
                mode.bgImage
                
                VStack(alignment: .center, spacing: 8.0) {

                    TitleView(title: mode.name, logoName: mode.logoName)
                    CoopTimelineView(coopTimeline: timeline, numberOfEventsDisplayed: numberOfEventsDisplayed)

                    Spacer()
                    if timeline.events.count > numberOfEventsDisplayed {
                        Button {
                            showingSheet.toggle()
                        } label: {
                            Text("More Events")
                        }
                        .padding(.vertical, 4.0)
                        .padding(.horizontal, 12.0)
                        .background(.white.opacity(0.3))
                        .cornerRadius(10)
                        .splat1Font(size: 18)
                        .sheet(isPresented: $showingSheet) {
                            Splatoon3TimelineSheetView(timeline: self.timeline)
                                .clearModalBackground()
                                .environmentObject(eventViewSettings)

                        }
                    }
                }
                .frame(minHeight: 450, maxHeight: .infinity, alignment: .top)
                .padding()

            }
        }
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
        .splat2Font(size: 12)
    }
}

struct Splatoon3TimelineSheetView: View {
    
    let timeline : Splatoon3.TimelineType

    var body: some View {
        Splatoon3TimelineCard(timeline: self.timeline, numberOfEventsDisplayed: self.timeline.events.count)
    }
}

