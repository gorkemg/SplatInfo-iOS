//
//  TimelineCard.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct TimelineCard: View {
    
    public enum TimelineType {
        case gameModeTimeline(timeline: GameModeTimeline)
        case coopTimeline(timeline: CoopTimeline)
        
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
        
    }
    
    let timeline : TimelineType
    
    var body: some View {
        ZStack(alignment: .top) {
            color
            bgImage
            VStack {
                TitleView(title: timeline.modeName, logoName: timeline.logo)
                switch timeline {
                case .gameModeTimeline(timeline: let timeline):
                    GameModeTimelineView(events: Array(timeline.schedule.prefix(3)))
                case .coopTimeline(timeline: let timeline):
                    CoopTimelineView(coopTimeline: timeline)
                }
            }
            .padding(10.0)
        }
        .cornerRadius(30)
        .foregroundColor(.white)
    }
    
    var color : Color {
        switch timeline {
        case .gameModeTimeline(timeline: let timeline):
            switch timeline.modeType {
            case .regular:
                return Color("RegularModeColor")
            case .ranked:
                return Color("RankedModeColor")
            case .league:
                return Color("LeagueModeColor")
            }
        case .coopTimeline(timeline: _):
            return Color("CoopModeColor")
        }
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

struct TimelineCard_Previews: PreviewProvider {
    
    static let exampleSchedule = Schedule.example
    
    static var previews: some View {
        TimelineCard(timeline: .gameModeTimeline(timeline: exampleSchedule.gameModes.regular))
            .previewLayout(.sizeThatFits)
        TimelineCard(timeline: .gameModeTimeline(timeline: exampleSchedule.gameModes.ranked))
            .previewLayout(.sizeThatFits)
        TimelineCard(timeline: .gameModeTimeline(timeline: exampleSchedule.gameModes.league))
            .previewLayout(.sizeThatFits)
        TimelineCard(timeline: .coopTimeline(timeline: exampleSchedule.coop))
            .previewLayout(.sizeThatFits)
    }
}
