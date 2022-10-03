//
//  TimelineCard.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

extension GameModeTimeline {
    
    var color: Color {
        switch self.mode {
        case .splatoon2(let type):
            switch type {
            case .turfWar:
                return Color.regularModeColor
            case .ranked:
                return Color.rankedModeColor
            case .league:
                return Color.leagueModeColor
            case .salmonRun:
                return Color.coopModeColor
            }
        case .splatoon3(let type):
            switch type {
            case .splatfest:
                return Color.regularModeColor
            case .turfWar:
                return Color.regularModeColor
            case .anarchyBattleOpen:
                return Color.rankedModeColor
            case .anarchyBattleSeries:
                return Color.rankedModeColor
            case .league:
                return Color.leagueModeColor
            case .x:
                return Color.rankedModeColor
            case .salmonRun:
                return Color.coopModeColor
            }
        }
    }
    
    var bgImage: Image {
        switch self.mode {
        case .splatoon2(let type):
            switch type {
            case .turfWar, .ranked, .league:
                return Image("splatoon-card-bg").resizable(resizingMode: .tile)
            case .salmonRun:
                return Image("bg-spots").resizable(resizingMode: .tile)
            }
        case .splatoon3(let type):
            switch type {
            case .splatfest, .turfWar, .anarchyBattleOpen, .anarchyBattleSeries, .league, .x:
                return Image("splatoon-card-bg").resizable(resizingMode: .tile)
            case .salmonRun:
                return Image("bg-spots").resizable(resizingMode: .tile)
            }
        }
    }
}

struct Splatoon2TimelineCard: View {
    
    let timeline : Splatoon2.TimelineType

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
                    GameModeTimelineView(mode: .splatoon2(type: mode), events: Array(timeline.upcomingEventsAfterDate(date: Date()).prefix(4)))
                    Spacer()
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
                }
                .frame(minHeight: 450, maxHeight: .infinity, alignment: .top)
                .padding()

            }
        }
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
        .splat2Font(size: 12)
    }
}

struct Splatoon3TimelineCard: View {

    let timeline : Splatoon3.TimelineType

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
                    GameModeTimelineView(mode: .splatoon3(type: mode), events: Array(timeline.upcomingEventsAfterDate(date: Date()).prefix(4)))
                    Spacer()
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
                }
                .frame(minHeight: 450, maxHeight: .infinity, alignment: .top)
                .padding()

            }
        }
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
        .splat2Font(size: 12)
    }
}

