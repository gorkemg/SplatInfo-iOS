//
//  SmallGameModeWidgetView.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 31.10.20.
//

import SwiftUI

struct SmallGameModeWidgetView : View {
    let gameMode: GameModeType
    let event: GameModeEvent
    var nextEvent: GameModeEvent? = nil
    let date: Date

    var body: some View {

        ZStack(alignment: .topTrailing){
            ZStack(alignment: .topLeading) {
                event.mode.color
                event.mode.bgImage

                GameModeEventView(gameMode: gameMode, event: event, nextEvent: nextEvent, style: .topBottom, date: date)
            }
        }
    }
}
