//
//  GameModeEventView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct GameModeEventView: View {
    let event: GameModeEvent
    let style: Style
    var date: Date
    
    var isTitleVisible: Bool = true
    var isModeLogoVisible: Bool = true
    var isModeTypeVisible: Bool = true
    var isRuleLogoVisible: Bool = true
    var isRuleNameVisible: Bool = true

    enum Style {
        case large
        case threeColumns
        case narrow
    }
    
    var isTurfWar : Bool {
        return event.mode.isTurfWar
    }
    
    var body: some View {
        VStack {
            switch style {
            case .large:
                ZStack(alignment: .topLeading) {
                    
                    HStack {
                        if let stage = event.stageA {
                            PillStageImage(stage: stage) //, height: innerGeo.size.height)
                        }
                        if let stage = event.stageB {
                            PillStageImage(stage: stage) //, height: innerGeo.size.height)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        HStack(alignment: .center, spacing: 2.0) {

                            if isTitleVisible {
                                GameModeEventTitleView(event: event, gameLogoPosition: .trailing, isTitleVisible: isTitleVisible, isModeLogoVisible: isModeLogoVisible, isModeTypeVisible: isModeTypeVisible, isRuleLogoVisible: isRuleLogoVisible, isRuleNameVisible: isRuleNameVisible)
                            }
                        }
                        Spacer()
                        HStack(alignment: .center, spacing: 4.0) {
                            let state = event.timeframe.state(date: date)
                            RelativeTimeframeView(timeframe: event.timeframe, state: state)
                                .splat2Font(size: 12).lineLimit(1).minimumScaleFactor(0.5).multilineTextAlignment(.trailing)
                            if state != .active {
                                ColoredActivityTextView(state: state)
                                    .splat2Font(size: 12)
                                    .shadow(color: .black, radius: 1.0, x: 0.0, y: 1.0)
                            }
                        }
                    }.padding(.horizontal, 6).padding(.vertical, 4.0)

                }

            case .threeColumns:
                GeometryReader { innerGeo in
                    
                    HStack(alignment: .center) {
                        
                        VStack(alignment: .center, spacing: 0.5) {
                            HStack(alignment: .center, spacing: 2.0){
                                if isRuleLogoVisible {
                                    Image(event.rule.logoNameSmall).resizable().aspectRatio(contentMode: .fit).frame(width: 16).shadow(color: .black, radius: 1, x: 0, y: 1)
                                }
                                Text(event.rule.name).splat2Font(size: 16)
                                    .lineLimit(1)
                                    .lineSpacing(0.2)
                                    .minimumScaleFactor(0.6)
                                    .multilineTextAlignment(.center)
                            }
                            TimeframeView(timeframe: event.timeframe, datesStyle: .never, fontSize: 12)
                                .lineLimit(2).minimumScaleFactor(0.4).multilineTextAlignment(.center)
                        }.frame(minWidth: min(80,innerGeo.size.width/3), maxWidth: innerGeo.size.width/3)

                        if let stage = event.stageA {
                            PillStageImage(stage: stage) //, height: innerGeo.size.height)
                        }

                        if let stage = event.stageB {
                            PillStageImage(stage: stage) //, height: innerGeo.size.height)
                        }
                    }
                    
                }.frame(minHeight: 40, idealHeight: 50, maxHeight: 60)

            case .narrow:
                GeometryReader { innerGeo in
                    LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
                        Group {
                            if let stage = event.stageA {
                                PillStageImage(stage: stage)
                            }
                        }
                        Group {
                            if let stage = event.stageB {
                                PillStageImage(stage: stage)
                            }
                        }
                    }
                }
                
            }
        }
    }

}

extension GameModeEvent {
    var stageA : Stage? {
        return stages.first
    }
    var stageB : Stage? {
        return stages.last
    }
    
    var gameLogo: Image {
        switch self.mode {
        case .splatoon2(_):
            return Image("Splatoon2_number_icon")
        case .splatoon3(_):
            return Image("Splatoon3_number_icon")
        }
    }
}

struct GameModeEventTitleView: View {
    let event: GameModeEvent
    var gameLogoPosition: GameLogoPosition = .hidden

    enum Style {
        case oneLine
        case twoLines
    }
    
    var isTitleVisible: Bool = true
    var isModeLogoVisible: Bool = true
    var isModeTypeVisible: Bool = true
    var isRuleLogoVisible: Bool = true
    var isRuleNameVisible: Bool = true

    enum GameLogoPosition {
        case hidden
        case leading
        case trailing
    }
    
    var gameLogo: some View {
        event.gameLogo.resizable().aspectRatio(contentMode: .fit)
            .frame(maxWidth: 20, maxHeight: 18).shadow(color: .black, radius: 1.0)
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.0){
            HStack(alignment: .center, spacing: 4.0) {
                if gameLogoPosition == .leading {
                    gameLogo
                }
                VStack(alignment: .center, spacing: 0.0){
                    if isModeLogoVisible {
                        modeLogoImage.resizable().aspectRatio(contentMode: .fit).frame(width: 24).shadow(color: .black, radius: 1, x: 0.0, y: 1.0)
                    }
                }
                if isRuleLogoVisible {
                    Image(event.rule.logoNameSmall).resizable().aspectRatio(contentMode: .fit).frame(width: 24).shadow(color: .black, radius: 1, x: 0, y: 1)
                }
                if isRuleNameVisible {
                    Text(event.rule.name).splat2Font(size: 14)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                if gameLogoPosition == .trailing {
                    gameLogo
                }
            }
            
            if isModeTypeVisible, case .splatoon3(let type) = event.mode {
                switch type {
                case .anarchyBattleOpen:
                    Splatoon3TagView(text: "Open")
                case .anarchyBattleSeries:
                    Splatoon3TagView(text: "Series")
                default:
                    Group{}
                }
            }

        }
    }
    
    var modeLogoImage: Image {
        if let uiImage = uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(event.mode.logoNameSmall)
    }
    
    
    var uiImage: UIImage? {
        if let image = UIImage(named: event.mode.logoName) {
            return image
        }
        return UIImage(named: event.mode.logoNameSmall)
    }
}

struct Splatoon3TagView: View {
    let text: String
    var backgroundColor: Color = .rankedModeColor
    var body: some View {
        Text(text)
            .splat2Font(size: 10)
            .minimumScaleFactor(0.5)
            .padding(.vertical, 0)
            .padding(.horizontal, 1.0)
            .background(backgroundColor)
            .cornerRadius(4.0)
            .shadow(color: .black, radius: 1, x: 0.0, y: 1.0)
    }
}
