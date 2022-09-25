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

//struct TimelineCard: View {
//
////    public enum TimelineType {
////        case gameModeTimeline(timeline: Splatoon2.GameModeTimeline)
////        case coopTimeline(timeline: CoopTimeline)
////
////        var modeName : String {
////            switch self {
////            case .gameModeTimeline(timeline: let timeline):
////                if let name = timeline.schedule.first?.mode.name {
////                    return name
////                }
////                return timeline.modeType.rawValue
////            case .coopTimeline(timeline: _):
////                return "Salmon Run"
////            }
////        }
////
////        var logo : String {
////            switch self {
////            case .gameModeTimeline(timeline: let timeline):
////                switch timeline.modeType {
////                case .turfWar:
////                    return "regular-logo"
////                case .ranked:
////                    return "ranked-logo"
////                case .league:
////                    return "league-logo"
////                }
////            case .coopTimeline(timeline: _):
////                return "mr-grizz-logo"
////            }
////        }
////
////        var color : Color {
////            switch self {
////            case .gameModeTimeline(timeline: let timeline):
////                switch timeline.modeType {
////                case .turfWar:
////                    return Color.regularModeColor
////                case .ranked:
////                    return Color.rankedModeColor
////                case .league:
////                    return Color.leagueModeColor
////                }
////            case .coopTimeline(timeline: _):
////                return Color.coopModeColor
////            }
////        }
////    }
//
//    enum TimelineType {
//        case game(timeline: GameModeTimeline)
//        case coop(game: Game, timeline: CoopTimeline)
//    }
//
//    let timeline : TimelineType
//
//    var body: some View {
//        ZStack(alignment: .top) {
//            ContainerRelativeShape()
//                            .inset(by: 4)
////            timeline.color
////            timeline.bgImage
//
//            switch timeline {
//            case .game(let timeline):
//
//                switch timeline.mode {
//                case .splatoon2(let type):
//
//                    VStack(alignment: .center, spacing: 8.0) {
//
//                        TitleView(title: timeline.mode.name, logoName: timeline.mode.logoName)
//
//                        switch timeline.timeline {
//                        case .regular(let events):
//                            GameModeTimelineView(events: Array(events.prefix(4)))
//                        case .coop(let events, let otherTimeframes):
//                            CoopTimelineView(coopTimeline: .init(events: events, otherTimeframes: otherTimeframes))
//                        }
//                        Spacer()
//                    }
//                    .frame(minHeight: 450, maxHeight: .infinity, alignment: .top)
//                    .padding()
//
//                    break
//                case .splatoon3(let type):
//                    break
//                }
//
//            case .coop(let game, let timeline):
//                CoopTimelineView(coopTimeline: timeline)
//            }
//        }
//        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30)))
//        .splat2Font(size: 12)
//    }
//
////    var bgImage : Image {
////        switch timeline {
////        case .gameModeTimeline(timeline: _):
////            return Image("splatoon-card-bg").resizable(resizingMode: .tile)
////        case .coopTimeline(timeline: _):
////            return Image("bg-spots").resizable(resizingMode: .tile)
////        }
////    }
//}

struct Splatoon2TimelineCard: View {

    enum TimelineType {
        case game(mode: Splatoon2.GameModeType, timeline: GameTimeline)
        case coop(timeline: CoopTimeline)
    }

//    var timelineView: some View {
//
//        switch timeline {
//        case .game(let mode, let timeline):
//
//            Text("")
//
//        case .coop(let timeline):
//
////                timeline.color
////                timeline.bgImage
//
//            CoopTimelineView(coopTimeline: timeline)
//        }
//
//    }
    
    
    let timeline : TimelineType

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
                    GameModeTimelineView(mode: .splatoon2(type: mode), events: Array(timeline.events.prefix(4)))
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

    enum TimelineType {
        case game(mode: Splatoon3.GameModeType, timeline: GameTimeline)
        case coop(timeline: CoopTimeline)
    }

    let timeline : TimelineType

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
                    GameModeTimelineView(mode: .splatoon3(type: mode), events: Array(timeline.events.prefix(4)))
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

extension Color {
    
    static var regularModeColor: Color {
        return Color("RegularModeColor")
    }
    static var rankedModeColor: Color {
        return Color("RankedModeColor")
    }
    static var leagueModeColor: Color {
        return Color("LeagueModeColor")
    }
    static var coopModeColor: Color {
        return Color("CoopModeColor")
    }
}

//struct TimelineCard_Previews: PreviewProvider {
//
//    static let exampleSchedule = Splatoon2.Schedule.example
//
//    static var previews: some View {
////        TimelineCard(timeline: .gameModeTimeline(timeline: exampleSchedule.gameModes.turfWar)).environmentObject(imageQuality)
////            .previewLayout(.sizeThatFits)
////        TimelineCard(timeline: .gameModeTimeline(timeline: exampleSchedule.gameModes.ranked))
////            //.previewLayout(.sizeThatFits)
////        TimelineCard(timeline: .gameModeTimeline(timeline: exampleSchedule.gameModes.league))
////            //.previewLayout(.sizeThatFits)
//
//        TimelineCard(timeline: .splatoon2(timeline: exampleSchedule.regular))
//            .previewDevice("iPad Air (5th generation)")
//            .environmentObject(imageQuality)
//            .previewLayout(.device)
//    }
//    static var imageQuality : ImageQuality {
//        let quality = ImageQuality()
//        quality.thumbnail = false
//        return quality
//    }
//}
