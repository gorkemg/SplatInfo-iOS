//
//  SplatoonKit.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 16.10.20.
//

import Foundation

enum Game {
    case splatoon2
    case splatoon3
}

enum GameTimelines {
    case splatoon2(timelines: Splatoon2.GameModeTimeline)
    case splatoon3(timelines: Splatoon3.GameModeTimeline)
}


struct Splatoon3 {
    
    enum GameModeType: String, Codable {
        case turfWar
        case anarchyBattleOpen
        case anarchyBattleSeries
        case league
        case x
        case salmonRun

        var logoName : String {
            switch self {
            case .turfWar:
                return "regular-logo"
            case .anarchyBattleOpen:
                return "ranked-logo"
            case .anarchyBattleSeries:
                return "ranked-logo"
            case .league:
                return "league-logo"
            case .x:
                return "league-logo"
            case .salmonRun:
                return "league-logo"
            }
        }
    }
    
    struct GameModeTimeline {
        let type: GameModeType
        let schedule: [GameModeEvent]

        var upcomingEvents : [GameModeEvent] {
            let filtered = upcomingEventsAfterDate(date: Date())
            if filtered.count == 0 {
                return schedule
            }
            return filtered
        }
        func upcomingEventsAfterDate(date: Date) -> [GameModeEvent] {
            return schedule.filter({ $0.timeframe.state(date: date) != .over })
        }
        
        static func empty(_ mode: GameModeType) -> GameModeTimeline {
            return GameModeTimeline(type: mode, schedule: [])
        }
    }
    
    struct GameModeEvent {
        let id: String
        var stages: [Stage]
        var rule: GameModeRule
        let timeframe: EventTimeframe
    }
    
    enum GameModeRule: String {
        case turf = "TURF_WAR"  // Turf War
        case area = "AREA"  // Zones
        case loft = "LOFT"  // Tower
        case goal = "GOAL"  // Rainmaker
        case clam = "CLAM"  // Clam Blitz
    }
}

struct Splatoon2 {

    struct GameModeTimeline: Codable {
        let modeType: GameModeType
        let schedule: [GameModeEvent]
        
        var upcomingEvents : [GameModeEvent] {
            let filtered = upcomingEventsAfterDate(date: Date())
            if filtered.count == 0 {
                return schedule
            }
            return filtered
        }
        func upcomingEventsAfterDate(date: Date) -> [GameModeEvent] {
            return schedule.filter({ $0.timeframe.state(date: date) != .over })
        }
        
        static func empty(_ mode: GameModeType) -> GameModeTimeline {
            return GameModeTimeline(modeType: mode, schedule: [])
        }
    }

    struct GameMode: Codable {
        let name: String
        let type: GameModeType
    }

    enum GameModeType: String, Codable {
        case league
        case ranked
        case regular

        var logoName : String {
            switch self {
            case .regular:
                return "regular-logo"
            case .ranked:
                return "ranked-logo"
            case .league:
                return "league-logo"
            }
        }
    }

    struct GameModeEvent: Codable, Equatable {
        let id: String
        let mode: GameMode
        let timeframe: EventTimeframe
        let stages: [Stage]
        let rule: GameModeRule
        
        static func == (lhs: GameModeEvent, rhs: GameModeEvent) -> Bool {
            return lhs.id == rhs.id
        }
    }

    struct GameModeRule: Codable {
        let key: String
        let name: String
    }

}

// MARK: - Coop

struct CoopTimeline: Codable {
    let detailedEvents: [CoopEvent]
    let eventTimeframes: [EventTimeframe]

    static func empty() -> CoopTimeline {
        return CoopTimeline(detailedEvents: [], eventTimeframes: [] /*, date: Date() */ )
    }
}

struct CoopEvent: Codable, Equatable {
    var id = UUID().uuidString
    let timeframe: EventTimeframe
    let weapons: [Weapon]
    let stage: Stage
    
    var logoName : String {
        return "mr-grizz-logo"
    }
    var modeName : String {
        return "Salmon Run"
    }
    static func == (lhs: CoopEvent, rhs: CoopEvent) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Stage

struct Stage: Codable {
    let id: String
    let name: String
    let imageUrl: URL?
}

// MARK: - Weapon

enum Weapon: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: WeaponCodingKeys.self)
        if let details = try container.decodeIfPresent(WeaponDetails.self, forKey: .weapon) {
            self = .weapon(details: details)
        }else if let details = try container.decodeIfPresent(WeaponDetails.self, forKey: .weapon) {
            self = .coopSpecialWeapon(details: details)
        }else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unable to decode Weapon enum"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: WeaponCodingKeys.self)
        switch self {
        case .weapon(details: let details):
            try container.encode(details, forKey: .weapon)
        case .coopSpecialWeapon(details: let details):
            try container.encode(details, forKey: .coopSpecialWeapon)
        }
    }
    
    enum WeaponCodingKeys: CodingKey {
        case weapon
        case coopSpecialWeapon
    }
    
    case weapon(details: WeaponDetails)
    case coopSpecialWeapon(details: WeaponDetails)
}

struct WeaponDetails: Codable {
    let id: String
    let name: String
    let imageUrl: URL?
}

extension CoopTimeline {
    
    var firstEvent: CoopEvent? {
        return detailedEvents.first
    }

    var secondEvent: CoopEvent? {
        if detailedEvents.count > 1 {
            return detailedEvents[1]
        }
        return nil
    }

    
    func eventChangingDates() -> [Date] {
        let now = Date()
        let startDates = detailedEvents.map({ $0.timeframe.startDate })
        let endDates = detailedEvents.map({ $0.timeframe.endDate })
        var eventDates = (startDates+endDates).sorted()
        if let firstDate = eventDates.first, now < firstDate {
            eventDates.insert(now, at: 0)
        }
        return eventDates
    }
    
    func upcomingEventsAfterDate(date: Date) -> [CoopEvent] {
        return detailedEvents.filter({ $0.timeframe.state(date: date) != .over })
    }

    func upcomingTimeframesAfterDate(date: Date) -> [EventTimeframe] {
        return eventTimeframes.filter({ $0.state(date: date) != .over })
    }
}

extension CoopEvent {
    var weaponDetails : [WeaponDetails] {
        var weaponDetails : [WeaponDetails] = []
        for weapon in weapons {
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

struct EventTimeframe: Codable, Hashable, TimeframeActivity {
    let startDate: Date
    let endDate: Date
}

struct CoopRandomWeapon: Codable {
    let name: String
    let imageUrl: String
}

struct CoopRewardGear: Codable {
    let startDate: Date
    let gear: Gear
}

struct SplatNetGear: Codable {
    let id: String
    let price: Int
    let skill: GearSkill
    let endDate: Date
    let gear: Gear
    let originalGear: OriginalGearDetails
}

struct Gear: Codable {
    let id: String
    let name: String
    let imageUrl: String
    let brand: GearBrand
    let rarity: Int
    let kind: GearKind
}

struct OriginalGearDetails: Codable {
    let name: String
    let price: Int
    let rarity: Int
    let skill: GearSkill
}

struct GearBrand: Codable {
    let id: String
    let name: String
    let imageUrl: String
    let frequentSkill: GearSkill?
}

struct GearSkill: Codable {
    let id: String
    let name: String
    let imageUrl: String
}

enum GearKind: String, Codable {
    case shoes
    case clothes
    case head
}

// MARK: - TimeframeActivity Protocol

protocol TimeframeActivity {
    
    var startDate : Date { get }
    var endDate : Date { get }
}

enum TimeframeActivityState {
    case active
    case soon
    case over
}

extension TimeframeActivity {
    
    func state(date: Date) -> TimeframeActivityState {
        
        if date < self.startDate {
            return .soon
        }
        if self.startDate <= date && date < self.endDate {
            return .active
        }
        return .over
    }

}
