//
//  SplatoonKit.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 16.10.20.
//

import Foundation

enum Game: Codable, Hashable {
    case splatoon2
    case splatoon3
}

enum GameTimelines {
    case splatoon2(schedule: Splatoon2.Schedule)
    case splatoon3(schedule: Splatoon3.Schedule)
}

enum ScheduleEvents: Codable {
    case regular(events: [GameModeEvent])
    case coop(events: [CoopEvent], otherTimeframes: [EventTimeframe])
}

enum GameModeType: Codable, Equatable, Hashable, Nameable, LogoNameable {
    case splatoon2(type: Splatoon2.GameModeType)
    case splatoon3(type: Splatoon3.GameModeType)

    var isTurfWar : Bool {
        switch self {
        case .splatoon2(let type):
            return type == .turfWar
        case .splatoon3(let type):
            return type == .turfWar
        }
    }

    var isSplatfest : Bool {
        switch self {
        case .splatoon2(_):
            return false
        case .splatoon3(let type):
            if case .splatfest(_) = type {
                return true
            }
            return false
        }
    }

    var name: String {
        switch self {
        case .splatoon2(let type):
            return type.name
        case .splatoon3(let type):
            return type.name
        }
    }
    
    var logoName: String {
        switch self {
        case .splatoon2(let type):
            return type.logoName
        case .splatoon3(let type):
            return type.logoName
        }
    }
    
    var logoNameSmall: String {
        switch self {
        case .splatoon2(let type):
            return type.logoNameSmall
        case .splatoon3(let type):
            return type.logoNameSmall
        }
    }
}

protocol Event: Codable {
    var timeframe: EventTimeframe { get }
}
struct GameModeEvent: Event, Identifiable, Equatable, Hashable {
    var id = UUID().uuidString
    var mode: GameModeType
    var stages: [Stage]
    var rule: GameModeRule
    let timeframe: EventTimeframe
    
    static func == (lhs: GameModeEvent, rhs: GameModeEvent) -> Bool {
        return lhs.id == rhs.id
    }
}

enum GameModeRule: String, Codable, Hashable, Nameable, LogoNameable {
    var name: String {
        switch self {
        case .turfWar:
            return "Turf War"
        case .splatZones:
            return "Splat Zones"
        case .towerControl:
            return "Tower Control"
        case .rainmaker:
            return "Rainmaker"
        case .clamBlitz:
            return "Clam Blitz"
        }
    }
            
    case turfWar = "TURF_WAR"  // Turf War
    case splatZones = "AREA"   // Zones
    case towerControl = "LOFT" // Tower
    case rainmaker = "GOAL"    // Rainmaker
    case clamBlitz = "CLAM"    // Clam Blitz
        
    var logoName: String {
        switch self {
        case .turfWar:
            return "rule-regular"
        case .splatZones:
            return "rule-area"
        case .towerControl:
            return "rule-yagura"
        case .rainmaker:
            return "rule-hoko"
        case .clamBlitz:
            return "rule-asari"
        }
    }
    
    var logoNameSmall: String {
        switch self {
        case .turfWar:
            return "rule-regular-small"
        case .splatZones:
            return "rule-area-small"
        case .towerControl:
            return "rule-yagura-small"
        case .rainmaker:
            return "rule-hoko-small"
        case .clamBlitz:
            return "rule-asari-small"
        }
    }

}

// MARK: - Coop
struct CoopTimeline: Codable, Hashable, Equatable {
    let game: Game
    var events: [CoopEvent]
    var otherTimeframes: [EventTimeframe]
    var gear: CoopGear?
}

struct CoopEvent: Hashable, Identifiable, Event {
    var id = UUID().uuidString
    let game: Game
    let timeframe: EventTimeframe
    let weapons: [Weapon]
    let stage: Stage
    
    var logoName : String {
        return "mode-coop" // "mr-grizz-logo"
    }
    var logoNameSmall : String {
        return "mode-coop-small" // "mr-grizz-logo-small"
    }
    var modeName : String {
        return "Salmon Run"
    }
    static func == (lhs: CoopEvent, rhs: CoopEvent) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Stage

struct Stage: Codable, Hashable {
    let id: String
    let name: String
    let imageUrl: URL?
}

// MARK: - Weapon

enum Weapon: Codable, Hashable {
    
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

struct WeaponDetails: Codable, Hashable {
    let id: String
    let name: String
    let imageUrl: URL?
}


protocol GameSchedule: Codable {
    var schedule: ScheduleEvents { get }
}

extension [GameModeEvent] {
    
    var upcomingEvents : [GameModeEvent] {
        return upcomingEventsAfterDate(date: Date())
    }

    func upcomingEventsAfterDate(date: Date) -> [GameModeEvent] {
        return self.filter({ $0.timeframe.state(date: date) != .over })
    }
}

extension [CoopEvent] {
    
    var upcomingEvents : [CoopEvent] {
        return upcomingEventsAfterDate(date: Date())
    }

    func upcomingEventsAfterDate(date: Date) -> [CoopEvent] {
        return self.filter({ $0.timeframe.state(date: date) != .over })
    }
}

protocol Nameable: Codable {
    var name: String { get }
}

protocol LogoNameable: Codable {
    var logoName: String { get }
    var logoNameSmall: String { get }
}

// MARK: - Splatoon 3 specific

struct Splatoon3: Codable {
        
    struct Schedule: Codable {
        var regular: GameTimeline
        var anarchyBattleOpen: GameTimeline
        var anarchyBattleSeries: GameTimeline
        var league: GameTimeline
        var x: GameTimeline
        var coop: CoopTimeline
        var splatfest: Splatfest

        struct Splatfest: Codable {
            let timeline: GameTimeline
            let fest: Fest?
            
            var activity: SplatfestActivity {
                guard let fest = fest else {
                    return .none
                }
                switch fest.state {
                case .scheduled:
                    return .upcoming
                case .firstHalf:
                    return .active(isFirstHalf: true)
                case .secondHalf:
                    return .active(isFirstHalf: false)
                case .closed:
                    return .over
                }
            }

            enum SplatfestActivity: Codable {
                case none
                case upcoming
                case active(isFirstHalf: Bool)
                case over
            }

            struct Fest: Codable, Hashable, Equatable {
                static func == (lhs: Splatoon3.Schedule.Splatfest.Fest, rhs: Splatoon3.Schedule.Splatfest.Fest) -> Bool {
                    return lhs.id == rhs.id
                }
                
                let id: String
                let timeframe: EventTimeframe
                let midtermTime: Date?
                let title: String
                let teams: [Team]
                let state: State
                let tricolorStage: Stage?

                struct Team: Codable, Hashable {
                    let id: String
                    let role: Role?
                    let color: RGBAColor
                    
                    enum Role: String, Hashable, Codable {
                        case attack = "ATTACK"
                        case defense = "DEFENSE"
                    }
                    
                    struct RGBAColor: Codable, Hashable {
                        let r: Float
                        let g: Float
                        let b: Float
                        let a: Float
                    }
                }
                
                enum State: String, Hashable, Codable {
                    case scheduled = "SCHEDULED"
                    case firstHalf = "FIRST_HALF"
                    case secondHalf = "SECOND_HALF"
                    case closed = "CLOSED"
                }
            }
        }
    }
    
    enum TimelineType: Codable, Hashable {
        case game(mode: Splatoon3.GameModeType, timeline: GameTimeline)
        case coop(timeline: CoopTimeline)
        
        var events: [Event] {
            switch self {
            case .game(_, let timeline):
                return timeline.events
            case .coop(let timeline):
                return timeline.events
            }
        }
        
        
        var modeType: Splatoon3.GameModeType {
            switch self {
            case .game(let mode, _):
                return mode
            case .coop(_):
                return Splatoon3.GameModeType.salmonRun
            }
        }
    }

    enum GameModeType: Codable, Equatable, Hashable, Nameable, LogoNameable {
        case splatfest(fest: Splatoon3.Schedule.Splatfest.Fest)
        case turfWar
        case anarchyBattleOpen
        case anarchyBattleSeries
        case league
        case x
        case salmonRun

        var name: String {
            switch self {
            case .splatfest:
                return "Splatfest"
            case .turfWar:
                return "Turf War"
            case .league:
                return "League Battle"
            case .salmonRun:
                return "Salmon Run"
            case .anarchyBattleOpen:
                return "Anarchy Battle Open"
            case .anarchyBattleSeries:
                return "Anarchy Battle Series"
            case .x:
                return "X Battle"
            }
        }

        var logoName : String {
            switch self {
            case .splatfest(_):
                return "mode-regular"
            case .turfWar:
                return "mode-regular"
            case .anarchyBattleOpen:
                return "mode-bankara"
            case .anarchyBattleSeries:
                return "mode-bankara"
            case .league:
                return "mode-league"
            case .x:
                return "mode-x"
            case .salmonRun:
                return "mr-grizz-logo"
//                return "mode-coop" //"mr-grizz-logo"
            }
        }

        var logoNameSmall : String {
            switch self {
            case .splatfest:
                return "mode-regular"
            case .turfWar:
                return "mode-regular" //"regular-logo-small"
            case .anarchyBattleOpen:
                return "mode-bankara" //"ranked-logo-small"
            case .anarchyBattleSeries:
                return "mode-bankara"
            case .league:
                return "mode-league" //"league-logo-small"
            case .x:
                return "mode-x"
            case .salmonRun:
                return "mr-grizz-logo-small"
//                return "mode-coop" //"mr-grizz-logo-small"
            }
        }
    }
    
//    struct CoopRewardGear: Codable {
//        let id: String
//        let type: GearKind
//        let name: String
//        let imageURL: URL
//    }
}

// MARK: - Splatoon 2 specific

struct GameModeTimeline: Codable {
    let mode: GameModeType
    let timeline: GameTimeline
}

struct GameTimeline: Codable, Hashable, Equatable {
    let events: [GameModeEvent]
}

protocol UpcomingEvents {

    associatedtype T
    func upcomingEventsAfterDate(date: Date) -> [T]
    var upcomingEvents: [T] { get }
}

extension GameTimeline: UpcomingEvents {
    var upcomingEvents: [GameModeEvent] {
        return self.upcomingEventsAfterDate(date: Date())
    }
    
    func upcomingEventsAfterDate(date: Date) -> [GameModeEvent] {
        return self.events.filter({ $0.timeframe.state(date: date) != .over })
    }
    
    func eventChangingDates() -> [Date] {
        let now = Date()
        let startDates = self.events.map({ $0.timeframe.startDate })
        let endDates = self.events.map({ $0.timeframe.endDate })
        var eventDates = (startDates+endDates).sorted()
        if let firstDate = eventDates.first, now < firstDate {
            eventDates.insert(now, at: 0)
        }
        return eventDates
    }
}

extension CoopTimeline: UpcomingEvents {
        
    var firstEvent: CoopEvent? {
        return self.events.first
    }

    var secondEvent: CoopEvent? {
        return self.events.second
    }
    
    func eventChangingDates() -> [Date] {
        let now = Date()
        let startDates = self.events.map({ $0.timeframe.startDate })
        let endDates = self.events.map({ $0.timeframe.endDate })
        var eventDates = (startDates+endDates).sorted()
        if let firstDate = eventDates.first, now < firstDate {
            eventDates.insert(now, at: 0)
        }
        return eventDates
    }

    var upcomingEvents: [CoopEvent] {
        return self.upcomingEventsAfterDate(date: Date())
    }

    func upcomingEventsAfterDate(date: Date) -> [CoopEvent] {
        return self.events.filter({ $0.timeframe.state(date: date) != .over })
    }
}

enum TimelineType: Codable, Hashable, Equatable {
    case game(mode: GameModeType, timeline: GameTimeline)
    case coop(game: Game, timeline: CoopTimeline)
    
    var modeType: GameModeType {
        switch self {
        case .game(let mode, _):
            return mode
        case .coop(let game, _):
            switch game {
            case .splatoon2:
                return .splatoon2(type: .salmonRun)
            case .splatoon3:
                return .splatoon3(type: .salmonRun)
            }
        }
    }
    
}

struct Splatoon2: Codable {
    
    enum TimelineType: Codable, Hashable, Equatable {
        case game(mode: Splatoon2.GameModeType, timeline: GameTimeline)
        case coop(timeline: CoopTimeline)
        
        var events: [Event] {
            switch self {
            case .game(_, let timeline):
                return timeline.events
            case .coop(let timeline):
                return timeline.events
            }
        }
        
        
        var modeType: Splatoon2.GameModeType {
            switch self {
            case .game(let mode, _):
                return mode
            case .coop(_):
                return Splatoon2.GameModeType.salmonRun
            }
        }
        
    }

    struct Schedule: Codable {
        var regular: GameTimeline
        var ranked: GameTimeline
        var league: GameTimeline
        var coop: CoopTimeline
    }
    
    enum GameModeType: String, Hashable, Equatable, Codable, Nameable, LogoNameable {
        case turfWar = "regular"
        case ranked
        case league
        case salmonRun

        var name: String {
            switch self {
            case .turfWar:
                return "Turf War"
            case .ranked:
                return "Ranked Battle"
            case .league:
                return "League Battle"
            case .salmonRun:
                return "Salmon Run"
            }
        }
        
        var logoName : String {
            switch self {
            case .turfWar:
                return "mode-regular" //"regular-logo"
            case .ranked:
                return "mode-bankara" //"ranked-logo"
            case .league:
                return "mode-league" //"league-logo"
            case .salmonRun:
                return "mr-grizz-logo"
//                return "mode-coop" //"mr-grizz-logo"
            }
        }

        var logoNameSmall : String {
            switch self {
            case .turfWar:
                return "mode-regular" //"regular-logo-small"
            case .ranked:
                return "mode-bankara" //"ranked-logo-small"
            case .league:
                return "mode-league" //"league-logo-small"
            case .salmonRun:
                return "mr-grizz-logo-small"
            }
        }
    }
}

// MARK: - Extensions

extension Array {
    var second: Element? {
        return self[safe: 1]
    }
    var third: Element? {
        return self[safe: 2]
    }
    var fourth: Element? {
        return self[safe: 3]
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}

//extension [CoopEvent] {
//
//    var firstEvent: CoopEvent? {
//        return self.first
//    }
//
//    var secondEvent: CoopEvent? {
//        return self.second
//    }
//
//    func eventChangingDates() -> [Date] {
//        let now = Date()
//        let startDates = self.map({ $0.timeframe.startDate })
//        let endDates = self.map({ $0.timeframe.endDate })
//        var eventDates = (startDates+endDates).sorted()
//        if let firstDate = eventDates.first, now < firstDate {
//            eventDates.insert(now, at: 0)
//        }
//        return eventDates
//    }
//
//    func upcomingEventsAfterDate(date: Date) -> [CoopEvent] {
//        return self.filter({ $0.timeframe.state(date: date) != .over })
//    }
//}

extension [EventTimeframe] {

    func upcomingTimeframesAfterDate(date: Date) -> [EventTimeframe] {
        return self.filter({ $0.state(date: date) != .over })
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

// MARK: - Gear

struct CoopGear: Codable, Hashable, Equatable {
    let id: String
    let type: GearKind
    let name: String
    let imageURL: URL
}

struct CoopRewardGear: Codable {
    let startDate: Date
    let gear: Gear
    
    var id: String {
        return gear.id
    }
    var type: GearKind {
        return gear.kind
    }
    var name: String {
        return gear.name
    }
    var imageURL: URL {
        return gear.imageUrl
    }
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
    let imageUrl: URL
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
