//
//  SplatoonKit.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 16.10.20.
//

import Foundation

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
        return schedule.filter({ $0.timeframe.status(date: date) != .over })
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

struct Stage: Codable {
    let id: String
    let name: String
    let imageUrl: String
}

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
    let imageUrl: String
}

struct CoopTimeline: Codable {
    let detailedEvents: [CoopEvent]
    let eventTimeframes: [EventTimeframe]
    let date: Date

    static func empty() -> CoopTimeline {
        return CoopTimeline(detailedEvents: [], eventTimeframes: [], date: Date())
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
//    var isActive : Bool { get }
//    var isUpcoming : Bool { get }
//    var isOver : Bool { get }
}

enum TimeframeActivityStatus {
    case active
    case soon
    case over
}

extension TimeframeActivity {
    
//    var isActive : Bool {
//        let date = Date()
//        return self.startDate <= date && date < self.endDate
//    }
//    var isUpcoming : Bool {
//        return Date() < self.startDate
//    }
//    var isOver : Bool {
//        return self.endDate < Date()
//    }
    
    func status(date: Date) -> TimeframeActivityStatus {
        
        if date < self.startDate {
            return .soon
        }
        if self.startDate <= date && date < self.endDate {
            return .active
        }
        return .over
    }

}
