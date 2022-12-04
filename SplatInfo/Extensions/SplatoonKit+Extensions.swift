//
//  SplatoonKit+Extensions.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 31.10.20.
//

import SwiftUI
import UIKit

extension Stage {
    
    var image : UIImage? {
        return assetImage ?? cachedImage() ?? cachedImage(directory: FileManager.default.appGroupContainerURL)
//        return nil
    }

    var thumbImage : UIImage? {
        return assetThumbImage ?? cachedImage() ?? cachedImage(directory: FileManager.default.appGroupContainerURL)
//        return nil
    }

    func cachedImage(directory: URL? = URL(fileURLWithPath: NSTemporaryDirectory())) -> UIImage? {
        let fileManager = FileManager.default
        let imageURL = imageUrl
        if let dir = directory, let url = imageURL {
            let fileURL = dir.appendingPathComponent(url.lastPathComponent)
            if fileManager.fileExists(atPath: fileURL.path) {
                return UIImage(contentsOfFile: fileURL.path)
            }else{
                // try JPEG
                let jpegURL = fileURL.deletingPathExtension().appendingPathExtension("jpeg")
                if fileManager.fileExists(atPath: jpegURL.path) {
                    return UIImage(contentsOfFile: jpegURL.path)
                }
            }
        }
        return nil
    }
    
    var assetImage: UIImage? {
        return UIImage(named: "\(id)") ?? UIImage(named: "\(id)")
    }

    var assetThumbImage: UIImage? {
        return UIImage(named: "thumb_\(id)") ?? UIImage(named: "\(id)")
    }
}

extension GameModeType {
    
    var color : Color {
        switch self {
        case .splatoon2(let type):
            return type.color
        case .splatoon3(let type):
            return type.color
        }
    }
    var bgImage: some View {
        Group {
            switch self {
            case .splatoon2(let type):
                type.bgImage
            case .splatoon3(let type):
                type.bgImage
            }
        }
    }
}

extension Splatoon2.GameModeType {

    var color : Color {
        switch self {
        case .turfWar:
            return Color.regularModeColor
        case .ranked:
            return Color.rankedModeColor
        case .league:
            return Color.leagueModeColor
        case .salmonRun:
            return Color.coopModeColor
        }
    }
    
    var bgImage: some View {
        Group {
            switch self {
            case .turfWar, .ranked, .league:
                return Image("splatoon-card-bg").resizable(resizingMode: .tile)
            case .salmonRun:
                return Image("bg-spots").resizable(resizingMode: .tile)
            }
        }
    }
}

extension Splatoon3.GameModeType {

    var color : Color {
        switch self {
        case .splatfest(_):
            return Color.white
        case .turfWar:
            return Color.regularModeColor
        case .anarchyBattleOpen:
            return Color.rankedModeColor
        case .anarchyBattleSeries:
            return Color.rankedModeColor
        case .league:
            return Color.leagueModeColor
        case .x:
            return Color.xModeColor
        case .salmonRun:
            return Color.coopModeColor
        }
    }

    var bgImage: some View {
        Group {
            switch self {
            case .splatfest(let fest):
                ZStack {
                    HStack(spacing: 0) {
                        ForEach(fest.teams, id: \.self) { team in
                            team.color.color
                        }
                    }.rotationEffect(Angle(degrees: -5.0)).scaleEffect(1.3)
                    Image("splatoon-card-bg").resizable(resizingMode: .tile)
                }
            case .turfWar, .anarchyBattleOpen, .anarchyBattleSeries, .league, .x:
                Image("splatoon-card-bg").resizable(resizingMode: .tile)
            case .salmonRun:
                Image("bg-spots").resizable(resizingMode: .tile)
            }
        }
    }
}

extension Splatoon3.Schedule.Splatfest.Fest.Team.RGBAColor {
    var color: Color {
        Color(red: Double(r), green: Double(g), blue: Double(b))
    }
    
}

extension Splatoon3.Schedule: CustomDebugStringConvertible {

    var debugDescription: String {
        var text = "Regular: \(regular)"
        text += "Anarchy Battle Open: \(anarchyBattleOpen)"
        text += "Anarchy Battle Series: \(anarchyBattleSeries)"
//        text += "League: \(league)"
//        text += "X: \(x)"
        text += "Coop: \(coop)"
        return text
    }
}

extension Splatoon2.Schedule: CustomDebugStringConvertible {

    var debugDescription: String {
        var text = "Regular: \(regular)"
        text += "Ranked: \(ranked)"
        text += "League: \(league)"
        text += "Coop: \(coop)"
        return text
    }
}

extension GameTimeline: CustomDebugStringConvertible {
    
    var debugDescription: String {
        var text = "Events: \(events.count)\n"
        for event in events {
            text += "\(event.mode) \(event.rule) \(event.timeframe)\n"
        }
        return text
    }
}

extension CoopTimeline: CustomDebugStringConvertible {
    
    var debugDescription: String {
        var text = "Events: \(events.count)\n"
        for event in events {
            text += "\(event.timeframe)\n"
        }
        return text
    }
}

extension GameModeType: CustomDebugStringConvertible {
    
    var debugDescription: String {
        switch self {
        case .splatoon2(let type):
            return type.name
        case .splatoon3(let type):
            return type.name
        }
    }
}

extension CoopEvent {

    var color : Color {
        return Color.coopModeColor
    }
}

extension EventTimeframe: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "\(startDate.formatted()) - \(endDate.formatted())"
    }
}

extension EventTimeframe {

    func relativeTimeText(date: Date) -> Text {
        return relativeTimeText(state: state(date: date))
    }

    func relativeTimeText(state: TimeframeActivityState) -> Text {
        switch state {
        case .active:
            return Text(endDate, style: .relative).monospacedDigit() + Text(" left")
        case .soon:
            return Text(" in ") + Text(startDate, style: .relative).monospacedDigit()
        case .over:
            return Text(" ended ") + Text(endDate, style: .relative).monospacedDigit() + Text(" ago")
        }
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
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
    static var xModeColor: Color {
        return Color("XModeColor")
    }
    static var coopModeColor: Color {
        return Color("CoopModeColor")
    }
}

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
