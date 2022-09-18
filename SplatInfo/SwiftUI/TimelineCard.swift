//
//  TimelineCard.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct TimelineCard: View {
    
    public enum TimelineType {
        case gameModeTimeline(timeline: Splatoon2.GameModeTimeline)
        case coopTimeline(timeline: Splatoon2.CoopTimeline)
        
        var modeName : String {
            switch self {
            case .gameModeTimeline(timeline: let timeline):
                if let name = timeline.schedule.first?.mode.name {
                    return name
                }
                return timeline.modeType.rawValue
            case .coopTimeline(timeline: _):
                return "Salmon Run"
            }
        }
        
        var logo : String {
            switch self {
            case .gameModeTimeline(timeline: let timeline):
                switch timeline.modeType {
                case .regular:
                    return "regular-logo"
                case .ranked:
                    return "ranked-logo"
                case .league:
                    return "league-logo"
                }
            case .coopTimeline(timeline: _):
                return "mr-grizz-logo"
            }
        }

        var color : Color {
            switch self {
            case .gameModeTimeline(timeline: let timeline):
                switch timeline.modeType {
                case .regular:
                    return Color.regularModeColor
                case .ranked:
                    return Color.rankedModeColor
                case .league:
                    return Color.leagueModeColor
                }
            case .coopTimeline(timeline: _):
                return Color.coopModeColor
            }
        }
    }
    
    let timeline : TimelineType
    
    var body: some View {
        ZStack(alignment: .top) {
            timeline.color
            bgImage
            VStack(alignment: .center, spacing: 8.0) {

                TitleView(title: timeline.modeName, logoName: timeline.logo)

                switch timeline {
                case .gameModeTimeline(timeline: let timeline):
                    GameModeTimelineView(events: Array(timeline.upcomingEvents.prefix(4)))
                case .coopTimeline(timeline: let timeline):
                    CoopTimelineView(coopTimeline: timeline)
                }

                Spacer()
            }
            .frame(minHeight: 450, maxHeight: .infinity, alignment: .top)
            .padding()
        }
        .cornerRadius(30)
        .splat2Font(size: 12)
    }
        
    var bgImage : Image {
        switch timeline {
        case .gameModeTimeline(timeline: _):
            return Image("splatoon-card-bg").resizable(resizingMode: .tile)
        case .coopTimeline(timeline: _):
            return Image("bg-spots").resizable(resizingMode: .tile)
        }
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

struct TimelineCard_Previews: PreviewProvider {
    
    static let exampleSchedule = Splatoon2Schedule.example
    
    static var previews: some View {
//        TimelineCard(timeline: .gameModeTimeline(timeline: exampleSchedule.gameModes.regular)).environmentObject(imageQuality)
//            .previewLayout(.sizeThatFits)
//        TimelineCard(timeline: .gameModeTimeline(timeline: exampleSchedule.gameModes.ranked))
//            //.previewLayout(.sizeThatFits)
//        TimelineCard(timeline: .gameModeTimeline(timeline: exampleSchedule.gameModes.league))
//            //.previewLayout(.sizeThatFits)
        TimelineCard(timeline: .coopTimeline(timeline: exampleSchedule.coop))
            .previewDevice("iPad Air (5th generation)")
            .environmentObject(imageQuality)
            .previewLayout(.device)
    }
    static var imageQuality : ImageQuality {
        let quality = ImageQuality()
        quality.thumbnail = false
        return quality
    }
}
