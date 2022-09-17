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
    let style: Style
    let state: TimeframeActivityState
    var showTitle: Bool = true
    var height: CGFloat? = nil

    enum Style {
        case large
        case sideBySide
        case narrow
    }
                
    var body: some View {
        switch style {
        case .large:
            CoopLargeEventView(event: event, state: state, showTitle: showTitle, height: height)
        case .sideBySide:
            CoopSideBySideEventView(event: event, state: state, showTitle: showTitle, height: height)
        case .narrow:
            CoopNarrowEventView(event: event, state: state, showTitle: showTitle, height: height)
        }
    }
}

struct CoopLargeEventView : View {
    let event: CoopEvent
    let state: TimeframeActivityState
    var showTitle: Bool = true
    var height: CGFloat? = nil
    @EnvironmentObject var imageQuality: ImageQuality

    var body: some View {
        GeometryReader { geo in
            ZStack {

                StageImage(stage: event.stage, height: height ?? geo.size.height)

                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            if showTitle {
                                CoopEventTitleView(event: event)
                            }
                            ColoredActivityTextView(state: state).splat2Font(size: 12)
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            VStack(alignment: .center, spacing: 0.0) {
                                Text("Available Weapons")
                                    .splat1Font(size: 12)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.5)
                                WeaponsList(weapons: event.weaponDetails)
                                    .frame(minHeight: 20, maxHeight: 30.0)
                                    .shadow(color: .black, radius: 2, x: 0, y: 1)
                                    .padding(.horizontal, 8.0)
                                    .background(Color.white.opacity(0.5).cornerRadius(8.0))
                            }
                        }

                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        VStack(alignment: .trailing) {
                            HStack(alignment: .center, spacing: 2.0) {

                                RelativeTimeframeView(timeframe: event.timeframe, state: state)
                                    .splat2Font(size: 14)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.trailing)
                            }
                            
                            ActivityTimeFrameView(timeframe: event.timeframe, state: state, fontSize: 12).lineLimit(1).minimumScaleFactor(0.5)
                        }

                    }
                }
                .padding(8)
                .cornerRadius(10)
            }
        }
    }
}

struct CoopNarrowEventView : View {
    let event: CoopEvent
    let state: TimeframeActivityState
    var showTitle: Bool = true
    var height: CGFloat? = nil
    @EnvironmentObject var imageQuality: ImageQuality

    var body: some View {
        GeometryReader { geo in
            ZStack {

                StageImage(stage: event.stage, height: height ?? geo.size.height)
                    .padding(0)

                HStack(alignment: .top) {
                    
                    VStack(alignment: .leading) {

                        HStack(alignment: .center) {
                            if showTitle {
                                CoopEventTitleView(event: event)
                            }
                            ColoredActivityTextView(state: state).splat2Font(size: 10)
                        }

                        Spacer()

                        WeaponsList(weapons: event.weaponDetails)
                            .frame(minHeight: 12, maxHeight: 24, alignment: .leading)
                            .shadow(color: .black, radius: 2, x: 0, y: 1)
                            .padding(.horizontal, 8.0)
                            .background(Color.white.opacity(0.5).cornerRadius(8.0))

                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        VStack(alignment: .trailing) {
                            HStack(alignment: .center, spacing: 2.0) {

                                RelativeTimeframeView(timeframe: event.timeframe, state: state)
                                    .splat2Font(size: 14)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                .multilineTextAlignment(.trailing)
                            }
                        }
                    }
                }
                .padding(4.0)
                .cornerRadius(10)
            }
        }
    }
}

struct CoopSideBySideEventView : View {
    let event: CoopEvent
    let state: TimeframeActivityState
    var showTitle: Bool = true
    var height: CGFloat? = nil
    @EnvironmentObject var imageQuality: ImageQuality

    var body: some View {
        HStack(alignment: .top, spacing: 8.0) {
            
            ZStack(alignment: .topLeading) {
                StageImage(stage: event.stage, height: height)

                HStack(alignment: .center, spacing: 2) {
                    VStack(alignment: .leading) {
                        if showTitle {
                            CoopEventTitleView(event: event)
                        }
                        ColoredActivityTextView(state: state).splat2Font(size: 10)
                    }
                    Spacer()
                    RelativeTimeframeView(timeframe: event.timeframe, state: state)
                        .splat2Font(size: 10)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.trailing)
                }.padding(2)
            }

            VStack(alignment: .leading, spacing: 2.0) {
                TimeframeView(timeframe: event.timeframe, datesStyle: .always, fontSize: 12)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                HStack(alignment: .center, spacing: 4.0) {
                    WeaponsList(weapons: event.weaponDetails)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                        .frame(minHeight: 12, maxHeight: 24, alignment: .leading)
                    Spacer()
                }
            }
        }.frame(maxHeight: 60)
    }
}

struct WeaponsList: View {
    let weapons: [WeaponDetails]
    
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(weapons, id: \.id) { weapon in
                WeaponImage(weapon: weapon)
            }
        }
    }
}

struct WeaponImage: View {
    let weapon: WeaponDetails

    var body: some View {
        if let image = weapon.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }else{
            AsyncImage(url: URL(string: weapon.imageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
        }
    }
}


extension WeaponDetails {
    
    var image : UIImage? {
        return assetImage ?? cachedImage() ?? cachedImage(directory: FileManager.default.appGroupContainerURL)
    }

    func cachedImage(directory: URL? = URL(fileURLWithPath: NSTemporaryDirectory())) -> UIImage? {
        let fileManager = FileManager.default
        let imageURL = URL(string: imageUrl)
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
        return UIImage(named: "weapon_\(id)")
    }

    var assetThumbImage: UIImage? {
        return UIImage(named: "weapon_thumb_\(id)")
    }
}

struct CoopEventTitleView: View {
    let event: CoopEvent
    var body: some View {
        HStack(alignment: .center, spacing: 4.0) {
            Image(event.logoName).resizable().aspectRatio(contentMode: .fit).frame(width: 20).shadow(color: .black, radius: 1, x: 0, y: 1)
            Text(event.modeName).splat2Font(size: 14).minimumScaleFactor(0.5).lineSpacing(0)
        }
    }
}

struct CoopEventView_Previews: PreviewProvider {

    static var previews: some View {

        if let coopEvent = Schedule.example.coop.firstEvent {
            CoopEventView(event: coopEvent, style: .narrow, state: .active)
            Text("no event")
        }else{
            Text("no event")
        }
    }
}
