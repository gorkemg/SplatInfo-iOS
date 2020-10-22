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
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var currentActivityText : String {
        return event.timeframe.isActive ? "Open!" : "Soon!"
    }
            
    var body: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            HStack {
                Text(currentActivityText).splat1Font(size: 20)
                Spacer()
                RelativeTimeframeView(timeframe: event.timeframe)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            }
            TimeframeView(timeframe: event.timeframe, datesEnabled: true)
            HStack {
                if let stage = event.stage {
                    StageImage(stage: stage)
                }
                VStack {
                    Text("Available Weapons").splat1Font(size: 14).minimumScaleFactor(0.5)
                    LazyVGrid(columns: columns, content: {
                        ForEach(weapons, id: \.id) { item in
                            AsyncImage(url: URL(string: item.imageUrl)!) {
                                Color.black.opacity(0.5)
                            } image: { (uiImage) in
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                    })
                }
            }
        }
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
