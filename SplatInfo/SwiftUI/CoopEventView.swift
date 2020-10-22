//
//  CoopEventView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 22.10.20.
//

import SwiftUI

struct CoopEventView: View {
    let details : CoopEvent
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Open or Soon")
                Text("Time remaining")
            }
            TimeframeView(timeframe: details.timeframe, datesEnabled: true)
            HStack {
                if let stage = details.stage {
                    StageImage(stage: stage)
                }
                VStack {
                    Text("Available Weapons")
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
        for weapon in details.weapons {
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
