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

    enum Style {
        case large
        case narrow
    }
                
    var body: some View {
        switch style {
        case .large:
            CoopLargeEventView(event: event, state: state)
        case .narrow:
            CoopNarrowEventView(event: event, state: state)
        }
    }
}

struct CoopLargeEventView : View {
    let event: CoopEvent
    let state: TimeframeActivityState

    var body: some View {
        VStack(alignment: .leading, spacing: 2.0) {
            
            HStack {
                Text(state.activityText).splat1Font(size: 14)
                Spacer()
                RelativeTimeframeView(timeframe: event.timeframe, state: state)
                    .splat2Font(size: 10)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            
            
            TimeframeView(timeframe: event.timeframe, datesEnabled: true, fontSize: 12)
            
            LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible())]) {
                if let stage = event.stage {
                    StageImage(stage: stage)
                }
                VStack(alignment: .center, spacing: 0.0) {
                    Text("Available Weapons")
                        .splat1Font(size: 12)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    WeaponsList(event: event)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                }
            }
        }
        .padding(10)
        .background(Color.black.opacity(0.5))
        .cornerRadius(10)
    }
}

struct CoopNarrowEventView : View {
    let event: CoopEvent
    let state: TimeframeActivityState

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(minimum: 40, maximum: 120)),GridItem(.flexible())]) {
            if let stage = event.stage {
                ZStack(alignment: .topLeading) {
                    StageImage(stage: stage, isNameVisible: false)
                    VStack(alignment: .leading) {
                        ImageOverlayText(text: state.activityText)
                        Spacer()
                        VStack {
                            if isInWidget() {
                                //RelativeTimeframeView(timeframe: event.timeframe, date: date)
                                Text(event.timeframe.startDate, style: .relative)
                                    .splat2Font(size: 10)
                                    .shadow(color: .black, radius: 1, x: 0.0, y: 1)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .padding(2)
                            }
                        }
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(4)
                    }.padding(2)
                }
            }else{
                Color.black.opacity(0.5)
            }
            VStack(alignment: .leading, spacing: 0) {
                if let stage = event.stage {
                    Text(stage.name).splat2Font(size: 11)
                }
                TimeframeView(timeframe: event.timeframe, datesEnabled: true, fontSize: 9).lineLimit(1).minimumScaleFactor(0.8)
                HStack {
                    WeaponsList(event: event)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                        .frame(maxHeight: 24, alignment: .leading)
                    Spacer()
                }
            }
        }.frame(minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
}

struct WeaponsList: View {
    let event: CoopEvent
    
    var body: some View {
        HStack(alignment: .center, spacing: 2, content: {
            ForEach(weapons, id: \.id) { weapon in
                if let image = weapon.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        })
    }

    var weapons : [WeaponDetails] {
        var weaponDetails : [WeaponDetails] = []
        for weapon in event.weapons {
            switch weapon {
            case .weapon(details: let details):
                weaponDetails.append(details)
            case .coopSpecialWeapon(details: let details):
                weaponDetails.append(details)
            }
        }
        return weaponDetails
    }
}

extension WeaponDetails {
    
    var image : UIImage? {
        return cachedImage() ?? cachedImage(directory: FileManager.default.appGroupContainerURL) ?? assetImage
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
        return UIImage(named: "weapon_thumb_\(id)") ?? UIImage(named: "\(id)")
    }
}
