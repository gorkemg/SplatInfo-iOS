//
//  EventViewSettings.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 23.10.22.
//

import Foundation

class EventViewSettings: ObservableObject {
    @Published var settings = Settings()

    init(settings: Settings = Settings()) {
        self.settings = settings
    }
    
    struct Settings {
        var useThumbnailQuality: Bool = false
        var showTitle: Bool = true
        var showModeLogo: Bool = true
        var showModeName: Bool = true
        var showModeType: Bool = true
        var showRuleLogo: Bool = true
        var showRuleName: Bool = true
        var showGameLogoAt: HorizontalPosition = .hidden
        var showMonthlyGear: Bool = true
    }
    
    enum HorizontalPosition {
        case hidden
        case leading
        case trailing
    }
    
    func copy() -> EventViewSettings {
        return EventViewSettings(settings: self.settings)
    }
}
