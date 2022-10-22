//
//  CoopEventView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

extension Date {
    
    func relativeTimeAhead(in locale: Locale = .current) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .numeric
        formatter.unitsStyle = .abbreviated
        formatter.locale = locale
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func relativeTimeRemaining(in locale: Locale = .current) -> String {
        let dateComponents = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: self)
        let componentFormatter = DateComponentsFormatter()
        componentFormatter.allowedUnits = [.day, .hour, .minute]
        componentFormatter.unitsStyle = .abbreviated
        componentFormatter.maximumUnitCount = 3
        componentFormatter.includesTimeRemainingPhrase = true
        return componentFormatter.string(from: dateComponents)!
    }
}

struct CoopEventView: View {
    let event : CoopEvent
    var gear: CoopGear?
    let style: Style
    let state: TimeframeActivityState
    var showTitle: Bool = true

    enum Style {
        case large
        case sideBySide
        case topBottom
        case narrow
    }
                
    var body: some View {
        switch style {
        case .large:
            CoopLargeEventView(event: event, gear: gear, state: state, showTitle: showTitle)
        case .sideBySide:
            CoopSideBySideEventView(event: event, gear: gear, state: state, showTitle: showTitle)
        case .topBottom:
            CoopTopBottomEventView(event: event, gear: gear, state: state)
        case .narrow:
            CoopNarrowEventView(event: event, gear: gear, state: state, showTitle: showTitle)
        }
    }
}

struct CoopLargeEventView : View {
    let event: CoopEvent
    var gear: CoopGear?
    let state: TimeframeActivityState
    var showTitle: Bool = true
    @EnvironmentObject var imageQuality: ImageQuality

    var body: some View {
        GeometryReader { geo in
            ZStack {

                PillStageImage(stage: event.stage)

                HStack(alignment: .top, spacing: 0.0) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            if showTitle {
                                CoopEventTitleView(event: event, gameLogoPosition: .trailing)
                            }
                        }
                        Spacer(minLength: 2.0)
                        VStack(alignment: .leading) {
                            HStack {
                                WeaponsList(weapons: event.weaponDetails)
                                    .frame(minHeight: 20, maxHeight: 40.0)
                                    .padding(.vertical, 2.0)
                                    .padding(.horizontal, 4.0)
                                #if !os(watchOS)
                                    .background(.ultraThinMaterial.opacity(0.9))
                                #else
                                    .background(Color.white.opacity(0.5))
                                #endif
                                    .cornerRadius(8.0)
                                    .clipShape(ContainerRelativeShape())
                                
                                if let gear = gear {
                                    GearImage(gear: gear)
                                        .frame(minHeight: 20, maxHeight: 40.0)
                                        .padding(.vertical, 2.0)
                                        .padding(.horizontal, 4.0)
                                    #if !os(watchOS)
                                        .background(.ultraThinMaterial.opacity(0.9))
                                    #else
                                        .background(Color.white.opacity(0.5))
                                    #endif
                                        .cornerRadius(8.0)
                                        .clipShape(ContainerRelativeShape())
                                }
                            }
                        }

                    }.background(.red)
                                        
                    VStack(alignment: .trailing) {
                        HStack(alignment: .center, spacing: 4.0) {

                            RelativeTimeframeView(timeframe: event.timeframe, state: state)
                                .splat2Font(size: 14)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.trailing)

                            if event.game == .splatoon2 {
                                ColoredActivityTextView(state: state)
                                    .scaledSplat2Font(size: 12)
                            }
                        }
                        
                        ActivityTimeFrameView(timeframe: event.timeframe, state: state, fontSize: 12).lineLimit(1).minimumScaleFactor(0.5)
                        
                        Spacer(minLength: 15)
                    }.background(.blue)
                }
                .padding(8.0)
            }
        }.frame(idealHeight: 200)
    }
}

struct CoopNarrowEventView : View {
    let event: CoopEvent
    var gear: CoopGear?
    let state: TimeframeActivityState
    var showTitle: Bool = true
    var height: CGFloat? = nil
    @EnvironmentObject var imageQuality: ImageQuality

    var body: some View {
        GeometryReader { geo in
            ZStack {

                PillStageImage(stage: event.stage, height: height ?? geo.size.height)//.opacity(0.1)

                HStack(alignment: .top) {
                    
                    VStack(alignment: .leading) {

                        HStack(alignment: .center) {
                            if showTitle {
                                CoopEventTitleView(event: event, gameLogoPosition: .trailing)
                            }
                        }

                        Spacer()

                        HStack {
                            WeaponsList(weapons: event.weaponDetails)
                                .frame(minHeight: 12, maxHeight: 24, alignment: .leading)
                                .padding(.vertical, 2.0)
                                .padding(.horizontal, 4.0)
                            #if !os(watchOS)
                                .background(.ultraThinMaterial.opacity(0.9))
                            #else
                                .background(Color.white.opacity(0.5))
                            #endif
                                .cornerRadius(4.0)
                                .clipShape(ContainerRelativeShape())
                            
                            if let gear = gear {
                                GearImage(gear: gear)
                                    .frame(minHeight: 12, maxHeight: 24.0)
                                    .padding(.vertical, 2.0)
                                    .padding(.horizontal, 4.0)
                                #if !os(watchOS)
                                    .background(.ultraThinMaterial.opacity(0.9))
                                #else
                                    .background(Color.white.opacity(0.5))
                                #endif
                                    .cornerRadius(4.0)
                                    .clipShape(ContainerRelativeShape())
                            }
                        }

                    }
                    
                    Spacer()

                    VStack(alignment: .trailing, spacing: 2.0) {
                        HStack(alignment: .center, spacing: 4.0) {

                            RelativeTimeframeView(timeframe: event.timeframe, state: state)
                                .splat2Font(size: 14)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.trailing)

                            if event.game == .splatoon2 {
                                ColoredActivityTextView(state: state)
                                    .scaledSplat2Font(size: 12)
                            }
                        }
                        
                        ActivityTimeFrameView(timeframe: event.timeframe, state: state, fontSize: 12).lineLimit(1).minimumScaleFactor(0.5)
                        
                        Spacer(minLength: 24)
                    }

//                    VStack(alignment: .trailing) {
//                        HStack(alignment: .center, spacing: 4.0) {
//
//                            RelativeTimeframeView(timeframe: event.timeframe, state: state)
//                                .splat2Font(size: 14)
//                                .lineLimit(1)
//                                .minimumScaleFactor(0.5)
//                                .multilineTextAlignment(.trailing)
//
//                            if state != .active {
//                                ColoredActivityTextView(state: state)
//                                    .scaledSplat2Font(size: 10)
//                            }
//                        }
//                        ActivityTimeFrameView(timeframe: event.timeframe, state: state)
//                            .lineLimit(1).minimumScaleFactor(0.5)
//                    }
                }
                .padding(.horizontal, 8.0).padding(.vertical, 4.0)
            }
        }
    }
}

struct CoopTopBottomEventView : View {
    let event: CoopEvent
    var gear: CoopGear?
    let state: TimeframeActivityState
    
    var body: some View {
        ZStack(alignment: .topLeading) {

            Color.coopModeColor

            Image("bg-spots").resizable(resizingMode: .tile)

            PillStageImage(stage: event.stage, namePosition: .hidden)
                        
            VStack(alignment: .leading, spacing: 0.0) {
                
                VStack(alignment: .leading, spacing: 0.0) {
                    CoopEventTitleView(event: event, gameLogoPosition: .trailing)
                    HStack {
                        Text(event.stage.name).splat2Font(size: 10)
                        Spacer()
                        if let gear = gear, gear.image != nil {
                            GearImage(gear: gear)
                                .shadow(color: .black, radius: 1.0, x: 0.0, y: 0.0)
                                .frame(minHeight: 16, maxHeight: 24)
                                .padding(.horizontal, 4.0)
                            #if !os(watchOS)
                                .background(.ultraThinMaterial.opacity(0.9))
                            #else
                                .background(Color.white.opacity(0.5))
                            #endif
                                .cornerRadius(8.0)
                        }
                    }
                }

                Spacer()
                
                VStack(alignment: .leading, spacing: 2.0) {
                    HStack {
                        if event.game == .splatoon2 {
                            ColoredActivityTextView(state: state)
                        }
                        RelativeTimeframeView(timeframe: event.timeframe, state: state)
                    }.splat2Font(size: 12)
                    
                    ActivityTimeFrameView(timeframe: event.timeframe, state: state).lineLimit(1).minimumScaleFactor(0.5)
                    HStack(spacing: 2.0) {
                        Group {
                            WeaponsList(weapons: event.weaponDetails)
                                .frame(maxHeight: 24.0)
                                .padding(.horizontal, 8.0)
                            #if !os(watchOS)
                                .background(.ultraThinMaterial.opacity(0.9))
                            #else
                                .background(Color.white.opacity(0.5))
                            #endif
                                .cornerRadius(8.0)
                        }
//                        Spacer()
                    }
                }.lineSpacing(0)
            }.padding(.horizontal, 10.0).padding(.vertical, 4.0)
        }.foregroundColor(.white)
    }
}

struct CoopSideBySideEventView : View {
    let event: CoopEvent
    var gear: CoopGear?
    let state: TimeframeActivityState
    var showTitle: Bool = true
    var height: CGFloat? = nil
    @EnvironmentObject var imageQuality: ImageQuality

    var body: some View {
        HStack(alignment: .top, spacing: 8.0) {
            
            ZStack(alignment: .topLeading) {
                PillStageImage(stage: event.stage, height: height)

                HStack(alignment: .center, spacing: 2) {
                    VStack(alignment: .leading) {
                        if showTitle {
                            CoopEventTitleView(event: event)
                        }
                        ColoredActivityTextView(state: state).scaledSplat2Font(size: 10)
                    }
                    Spacer()
                    RelativeTimeframeView(timeframe: event.timeframe, state: state)
                        .splat2Font(size: 10)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.trailing)
                }
                .padding(.horizontal, 4.0)
                .padding(.vertical, 2.0)

            }

            VStack(alignment: .leading, spacing: 2.0) {
                TimeframeView(timeframe: event.timeframe, datesStyle: .always, fontSize: 10)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.4)
                HStack(alignment: .center, spacing: 4.0) {
                    WeaponsList(weapons: event.weaponDetails, spacing: 4.0)
                        .frame(minHeight: 20, maxHeight: 24, alignment: .leading)
                    Spacer()
                    if let gear = gear {
                        GearImage(gear: gear)
                            .frame(minHeight: 20, maxHeight: 30)
                            .shadow(color: .black, radius: 1.0, x: 0.0, y: 0.0)
                    }
                }
            }
        }.frame(maxHeight: 60)
    }
    
    private var isiOS16: Bool {
            guard #available(iOS 16, *) else {
                return true
            }
            return false
        }
}

struct WeaponsList: View {
    let weapons: [WeaponDetails]
    var spacing: CGFloat? = 2.0
    
    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            ForEach(weapons.indices, id: \.self) { index in
                let weapon = weapons[index]
                WeaponImage(weapon: weapon)
                    .shadow(color: .black, radius: 1.0, x: 0.0, y: 0.0)
            }
        }
    }
}

struct WeaponImage: View {
    let weapon: WeaponDetails
    let imageLoaderManager = ImageLoaderManager()

    var body: some View {
        if let image = weapon.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }else{
            AsyncImage(url: weapon.imageUrl) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                #if !os(watchOS)
                ProgressView()
                #endif
            }
        }
    }
}

struct GearImage: View {
    let gear: CoopGear
    let imageLoaderManager = ImageLoaderManager()

    var body: some View {
        if let image = gear.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }else{
            AsyncImage(url: gear.imageURL) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                #if !os(watchOS)
                ProgressView()
                #endif
            }
        }
    }
}

extension CoopGear {
    
    var image : UIImage? {
        return assetImage ?? assetThumbImage ?? cachedImage() ?? cachedImage(directory: FileManager.default.appGroupContainerURL)
    }

    func cachedImage(directory: URL? = URL(fileURLWithPath: NSTemporaryDirectory())) -> UIImage? {
        let fileManager = FileManager.default
        if let dir = directory {
            let url = self.imageURL
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
        return UIImage(named: "gear_\(id)")
    }

    var assetThumbImage: UIImage? {
        return UIImage(named: "gear_thumb_\(id)")
    }
}


extension WeaponDetails {
    
    var image : UIImage? {
        return assetImage ?? assetThumbImage ?? cachedImage() ?? cachedImage(directory: FileManager.default.appGroupContainerURL)
    }

    func cachedImage(directory: URL? = URL(fileURLWithPath: NSTemporaryDirectory())) -> UIImage? {
        let fileManager = FileManager.default
        if let dir = directory, let url = imageUrl {
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
        return UIImage(named: "weapon_\(id)")
    }

    var assetThumbImage: UIImage? {
        return UIImage(named: "weapon_thumb_\(id)")
    }
}

struct CoopEventTitleView: View {
    let event: CoopEvent
    var gameLogoPosition: GameLogoPosition = .hidden

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
        HStack(alignment: .center, spacing: 4.0) {
            if gameLogoPosition == .leading {
                gameLogo
            }
            CoopLogo(event: event)
            Text(event.modeName).splat2Font(size: 14)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .lineSpacing(0)
            if gameLogoPosition == .trailing {
                gameLogo
            }
        }
    }
}

struct CoopLogo: View {
    let event: CoopEvent
    
    var body: some View {
        HStack {
            logoImage.resizable().aspectRatio(contentMode: .fit).frame(width: 20).shadow(color: .black, radius: 1, x: 0, y: 1)
        }
    }
    
    var logoImage: Image {
        if let uiImage = uiImage {
            return Image(uiImage: uiImage)
        }
        return Image(event.logoName)
    }
        
    var uiImage: UIImage? {
        if let image = UIImage(named: event.logoName) {
            return image
        }
        return UIImage(named: event.logoNameSmall)
    }
}

extension CoopEvent {
    
    var gameLogo: Image {
        switch self.game {
        case .splatoon2:
            return Image("Splatoon2_number_icon")
        case .splatoon3:
            return Image("Splatoon3_number_icon")
        }
    }
}

//struct CoopEventView_Previews: PreviewProvider {
//
//    static var previews: some View {
//
//        if let coopEvent = Splatoon2Schedule.example.coop.firstEvent {
//            CoopEventView(event: coopEvent, style: .narrow, state: .active).environmentObject(imageQuality)
//        }else{
//            Text("no event")
//        }
//    }
//    
//    static var imageQuality : ImageQuality {
//        let quality = ImageQuality()
//        quality.thumbnail = false
//        return quality
//    }
//}
