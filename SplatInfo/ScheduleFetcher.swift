//
//  ScheduleFetcher.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 16.10.20.
//

import Foundation
import Combine

private let splatnet2ImageHostUrl = "https://splatoon2.ink/assets/splatnet"

struct Splatoon2Schedule: Codable {
    var gameModes = GameModesTimelines.empty
    var coop = CoopTimeline.empty()
    
    static var empty : Splatoon2Schedule {
        return Splatoon2Schedule(gameModes: GameModesTimelines.empty, coop: CoopTimeline.empty())
    }
    
    static var example : Splatoon2Schedule {
        let schedulesPath = Bundle.main.path(forResource: "schedules", ofType: "json")
        guard let schedulesData = try? Data(contentsOf: URL(fileURLWithPath: schedulesPath!)) else { return Splatoon2Schedule.empty }
        guard let scheduleResponse : SchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: schedulesData) else { return Splatoon2Schedule.empty }
        let coopSchedulesPath = Bundle.main.path(forResource: "coop-schedules", ofType: "json")
        guard let coopSchedulesData = try? Data(contentsOf: URL(fileURLWithPath: coopSchedulesPath!)) else { return Splatoon2Schedule.empty }
        guard let coopScheduleResponse : CoopSchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: coopSchedulesData) else { return Splatoon2Schedule.empty }
        let schedule = Splatoon2Schedule(gameModes: scheduleResponse.gameModesTimelines, coop: coopScheduleResponse.coopTimeline)
        return schedule
    }
    
    func allImageURLs() -> [URL] {
        var imageURLs : [URL] = []
        let modes = [gameModes.regular, gameModes.ranked, gameModes.league]
        let stageImageURLs = modes.flatMap({ $0.allImageURLs() })
        imageURLs.append(contentsOf: stageImageURLs)
        
//        let coopStageImageURLStrings = coop.detailedEvents.flatMap({ $0.stage.imageUrl })
//        let coopWeaponImageURLStrings = coop.detailedEvents.flatMap({ $0.weapons.flatMap { (weapon) -> String in
//            switch weapon {
//            case .weapon(details: let details):
//                return details.imageUrl
//            case .coopSpecialWeapon(details: let details):
//                return details.imageUrl
//            }
//        } })
//        let coopImageURLs = [coopStageImageURLStrings,coopWeaponImageURLStrings].compactMap({ URL(string: String($0)) })
        let coopImageURLs = coop.allImageURLs()
        imageURLs.append(contentsOf: coopImageURLs)
        
        return imageURLs
    }
}

//struct Splatoon3Schedule: Codable {
//    var gameModes = GameModesTimelines.empty
//    var coop = CoopTimeline.empty()
//    
//    static var empty : Splatoon2Schedule {
//        return Splatoon2Schedule(gameModes: GameModesTimelines.empty, coop: CoopTimeline.empty())
//    }
//    
//    static var example : Splatoon2Schedule {
//        let schedulesPath = Bundle.main.path(forResource: "schedules", ofType: "json")
//        guard let schedulesData = try? Data(contentsOf: URL(fileURLWithPath: schedulesPath!)) else { return Splatoon2Schedule.empty }
//        guard let scheduleResponse : SchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: schedulesData) else { return Splatoon2Schedule.empty }
//        let coopSchedulesPath = Bundle.main.path(forResource: "coop-schedules", ofType: "json")
//        guard let coopSchedulesData = try? Data(contentsOf: URL(fileURLWithPath: coopSchedulesPath!)) else { return Splatoon2Schedule.empty }
//        guard let coopScheduleResponse : CoopSchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: coopSchedulesData) else { return Splatoon2Schedule.empty }
//        let schedule = Splatoon2Schedule(gameModes: scheduleResponse.gameModesTimelines, coop: coopScheduleResponse.coopTimeline)
//        return schedule
//    }
//    
//    func allImageURLs() -> [URL] {
//        var imageURLs : [URL] = []
//        let modes = [gameModes.regular, gameModes.ranked, gameModes.league]
//        let stageImageURLs = modes.flatMap({ $0.allImageURLs() })
//        imageURLs.append(contentsOf: stageImageURLs)
//        
////        let coopStageImageURLStrings = coop.detailedEvents.flatMap({ $0.stage.imageUrl })
////        let coopWeaponImageURLStrings = coop.detailedEvents.flatMap({ $0.weapons.flatMap { (weapon) -> String in
////            switch weapon {
////            case .weapon(details: let details):
////                return details.imageUrl
////            case .coopSpecialWeapon(details: let details):
////                return details.imageUrl
////            }
////        } })
////        let coopImageURLs = [coopStageImageURLStrings,coopWeaponImageURLStrings].compactMap({ URL(string: String($0)) })
//        let coopImageURLs = coop.allImageURLs()
//        imageURLs.append(contentsOf: coopImageURLs)
//        
//        return imageURLs
//    }
//}

//protocol Outdated {
//
//    var date : Date { get }
//    var isOutdated : Bool { get }
//}
//
//extension Outdated {
//
//    var isOutdated : Bool {
//        return self.date < Date().addingTimeInterval(-3600) // is stored date older than one hour ago
//    }
//}

struct GameModesTimelines: Codable /*, Outdated */ {
    let regular: Splatoon2.GameModeTimeline
    let ranked: Splatoon2.GameModeTimeline
    let league: Splatoon2.GameModeTimeline
//    let date: Date

    static var empty : GameModesTimelines {
        return GameModesTimelines(regular: Splatoon2.GameModeTimeline.empty(.regular), ranked: Splatoon2.GameModeTimeline.empty(.ranked), league: Splatoon2.GameModeTimeline.empty(.league))
    }
}

extension Splatoon2.GameModeTimeline {
    func allImageURLs() -> [URL] {
        let stages = self.schedule.flatMap({ $0.stages })
        let imageURLs = stages.map({ $0.imageUrl })
//        let stageImageURLStrings = self.schedule.flatMap({ $0.stages.flatMap({ $0.imageUrl }) })
//        let stageImageURLs = stageImageURLStrings.compactMap({ URL(string: String($0)) })
        let stageImageURLs = imageURLs.compactMap({ $0 /*URL(string: $0) */ })
        return stageImageURLs
    }
}

//extension CoopTimeline : Outdated {
//    // make CoopTimeline extend Outdated protocol
//}

extension CoopTimeline {
    func allImageURLs() -> [URL] {
        let coopStageImageURLStrings = allStageImageURLs()
        let coopWeaponImageURLStrings = allWeaponImageURLs()
        let imageURLs = coopStageImageURLStrings + coopWeaponImageURLStrings
//        let imageURLs = combined.compactMap({ URL(string: $0) })
        return imageURLs
    }
    
    func allStageImageURLs() -> [URL] {
        let coopStageImageURLStrings = self.detailedEvents.map({ $0.stage.imageUrl })
        return coopStageImageURLStrings.compactMap({ $0 /*URL(string: $0) */ })
    }
    
    func allWeaponImageURLs() -> [URL] {
        let coopWeaponImageURLs = self.detailedEvents.map({ $0.weapons.map { (weapon) -> URL? in
            switch weapon {
            case .weapon(details: let details):
                return details.imageUrl
            case .coopSpecialWeapon(details: let details):
                return details.imageUrl
            }
        } }).flatMap({ $0 })
        return coopWeaponImageURLs.compactMap({ $0 })
    }
}

//extension Encodable {
//    func toJSONData() -> Data? { try? JSONEncoder().encode(self) }
//}

extension Encodable {
    func encoded() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

extension Data {
    func decoded<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}

class ScheduleFetcher: ObservableObject {
    
    private let splat2API = Splatoon2InkAPI.shared()
    private let splat3API = Splatoon3InkAPI.shared()
    var defaultCacheDirectory: String = NSTemporaryDirectory()
    var useSharedFolderForCaching: Bool = false
    
    @Published var schedule : Splatoon2Schedule = Splatoon2Schedule.empty
    
    private func loadCachedData<T>(filename: String, resultType: T.Type) -> TimelineCache<T>? where T:Codable {
        let filePath = cacheFileURL(filename: filename)
        let fileManager = FileManager.default
        guard let path = filePath, fileManager.fileExists(atPath: path.path) else { return nil }
        guard let data = try? Data(contentsOf: path) else { return nil }
        guard let cache = try? JSONDecoder().decode(TimelineCache<T>.self, from: data) else { return nil }
        return cache
    }
    
    private func cacheData<T:Codable>(cacheData: TimelineCache<T>, filename: String) {
        let filePath = cacheFileURL(filename: filename)
        guard let path = filePath, let data = try? cacheData.encoded() else { return }
        try? data.write(to: path)
        copyCacheFileToAppGroupDirectory(filename)
    }
    
    struct TimelineCache<T: Codable>: Codable {
        let timeline: T
        let date: Date
        
        var isOutdated : Bool {
            return self.date < Date().addingTimeInterval(-3600) // is stored date older than one hour ago
        }
    }

    private func cacheFileURL(filename: String) -> URL? {
        if useSharedFolderForCaching, let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName) {
            return sharedContainerURL.appendingPathComponent(filename)
        }
        return NSURL(fileURLWithPath: defaultCacheDirectory).appendingPathComponent(filename)
    }
    
    private func copyCacheFileToAppGroupDirectory(_ filename: String) {
        let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupName)
        NSLog("sharedContainerURL = \(String(describing: sharedContainerURL))")
        guard let sourceURL = cacheFileURL(filename: filename) else { return }
        guard let destinationURL = sharedContainerURL?.appendingPathComponent(filename) else { return }
        try? FileManager().copyItem(at: sourceURL, to: destinationURL)
    }
    
    func fetchGameModeTimelines(completion: @escaping (_ timelines: GameModesTimelines?, _ error: Error?) -> Void) {
        
        let filename = "schedules.json"
        if let cacheData = loadCachedData(filename: filename, resultType: GameModesTimelines.self), !cacheData.isOutdated {
            self.schedule.gameModes = cacheData.timeline
            completion(cacheData.timeline, nil)
            return
        }
        
        splat2API.requestSchedules { [weak self] (response, error) in
            guard let self = self else { return }
            
            if let error = error {
                completion(nil, error)
                return
            }

            guard let response = response else {
                completion(nil, InvalidResponseError())
                return
            }

            let gameModesTimelines = response.gameModesTimelines
            let cacheData = TimelineCache(timeline: gameModesTimelines, date: Date())
            self.cacheData(cacheData: cacheData, filename: filename)
            self.schedule.gameModes = gameModesTimelines
            completion(gameModesTimelines, nil)
        }
        
        splat3API.requestSchedules { response, error in

            guard let data = response?.data else { return }
            print(data)
            
        }
    }
    
    func fetchCoopTimeline(completion: @escaping (_ timeline: CoopTimeline?, _ error: Error?) -> Void) {

        let filename = "coop-schedules.json"
        if let cacheData = loadCachedData(filename: filename, resultType: CoopTimeline.self), !cacheData.isOutdated {
            self.schedule.coop = cacheData.timeline
            completion(cacheData.timeline, nil)
            return
        }

        splat2API.requestCoopSchedules { [weak self] (coopResponse, error) in
            guard let self = self else { return }
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let coopResponse = coopResponse else {
                completion(nil, InvalidResponseError())
                return
            }
            
            let coopTimeline = coopResponse.coopTimeline
            let cacheData = TimelineCache(timeline: coopTimeline, date: Date())
            self.cacheData(cacheData: cacheData, filename: filename)
            self.schedule.coop = coopTimeline
            completion(coopTimeline, nil)
        }

    }
}

class InvalidResponseError: Error {
}

extension SchedulesAPIResponse {
    
    var gameModesTimelines : GameModesTimelines {
        let regularEvents = self.regular.map({ $0.gameModeEvent })
        let rankedEvents = self.gachi.map({ $0.gameModeEvent })
        let leagueEvents = self.league.map({ $0.gameModeEvent })
        
        let regular = Splatoon2.GameModeTimeline(modeType: .regular, schedule: regularEvents)
        let ranked = Splatoon2.GameModeTimeline(modeType: .ranked, schedule: rankedEvents)
        let league = Splatoon2.GameModeTimeline(modeType: .league, schedule: leagueEvents)
        let schedule = GameModesTimelines(regular: regular, ranked: ranked, league: league)
        return schedule
    }
}

extension Splatoon3InkAPI.SchedulesAPIResponse {

    var gameModesTimelines: [Splatoon3.GameModeTimeline] {

        let regularEvents = self.data.regularSchedules.nodes.flatMap({ $0.gameModeEvents })
        let anarchyBattleOpenEvents = self.data.bankaraSchedules.nodes.filter({ $0.bankaraMatchSettings.filter({ $0.mode == .open }).count > 0 }).flatMap({ $0.gameModeEvents })
        let anarchyBattleSeriesEvents = self.data.bankaraSchedules.nodes.filter({ $0.bankaraMatchSettings.filter({ $0.mode == .challenge }).count > 0 }).flatMap({ $0.gameModeEvents })
        
        var timelines: [Splatoon3.GameModeTimeline] = []
        
        let regularTimeline = Splatoon3.GameModeTimeline(type: .turfWar, schedule: regularEvents)
        let anarchyOpen = Splatoon3.GameModeTimeline(type: .anarchyBattleOpen, schedule: anarchyBattleOpenEvents)
        let anarchySeries = Splatoon3.GameModeTimeline(type: .anarchyBattleSeries, schedule: anarchyBattleSeriesEvents)
        timelines.append(regularTimeline)
        timelines.append(anarchyOpen)
        timelines.append(anarchySeries)
        return timelines
    }
    
    var coopTimeline: CoopTimeline {
        
        var events: [CoopEvent] = []
        let coopEvents = self.data.coopGroupingSchedule.regularSchedules.nodes
        for event in coopEvents {
            let coopEvent = CoopEvent(timeframe: EventTimeframe(startDate: event.startTime, endDate: event.endTime), weapons: event.setting.weapons.map({ $0.weapon }), stage: Stage(id: event.setting.coopStage.id, name: event.setting.coopStage.name, imageUrl: event.setting.coopStage.image.url))
            events.append(coopEvent)
        }
        return CoopTimeline(detailedEvents: events, eventTimeframes: [])
    }
    
}

extension Splatoon3InkAPI.Weapon {
    
    var weapon: Weapon {
        return .weapon(details: WeaponDetails(id: UUID().uuidString, name: self.name, imageUrl: self.image.url))
    }
    
}

extension Decodable where Self: EventDetails {
    
    var gameModeEvents: [Splatoon3.GameModeEvent] {
        var events: [Splatoon3.GameModeEvent] = []
        for setting in matchSetting {
            let event = Splatoon3.GameModeEvent(id: UUID().uuidString, stages: setting.stages, rule: setting.rule, timeframe: EventTimeframe(startDate: self.startTime, endDate: self.endTime))
            events.append(event)
        }
        return events
    }
}

extension MatchSetting {
    
    var stages: [Stage] {
        var stages: [Stage] = []
        for vsStage in vsStages {
            let stage = Stage(id: vsStage.id, name: vsStage.name, imageUrl: vsStage.image.url)
            stages.append(stage)
        }
        return stages
    }
    
    var rule: Splatoon3.GameModeRule {
        return .init(rawValue: self.vsRule.rule.rawValue) ?? .turf
    }
}

extension CoopSchedulesAPIResponse {
    
    var coopTimeline : CoopTimeline {
        var detailedEvents : [CoopEvent] = []
        for event in self.details {
            let timeframe = EventTimeframe(startDate: event.startTime, endDate: event.endTime)
            var weapons: [Weapon] = []
            for weaponDetails in event.weapons {
                
                if let weaponDetails = weaponDetails.weapon {
                    let details = WeaponDetails(id: weaponDetails.id, name: weaponDetails.name, imageUrl: URL(string: "\(splatnet2ImageHostUrl)\(weaponDetails.image)"))
                    let weapon = Weapon.weapon(details: details)
                    weapons.append(weapon)
                }else if let coopWeaponDetails = weaponDetails.coopSpecialWeapon {
                    let details = WeaponDetails(id: weaponDetails.id, name: coopWeaponDetails.name, imageUrl: URL(string: "\(splatnet2ImageHostUrl)\(coopWeaponDetails.image)"))
                    let weapon = Weapon.weapon(details: details)
                    weapons.append(weapon)
                }
            }
            let stage = Stage(id: coopStageID(name: event.stage.name), name: event.stage.name, imageUrl: URL(string: "\(splatnet2ImageHostUrl)\(event.stage.image)"))
            let eventDetails = CoopEvent(timeframe: timeframe, weapons: weapons, stage: stage)
            detailedEvents.append(eventDetails)
        }
        var eventTimeFrames : [EventTimeframe] = []
        for otherEvent in self.schedules {
            let timeframe = EventTimeframe(startDate: otherEvent.startTime, endDate: otherEvent.endTime)
            eventTimeFrames.append(timeframe)
        }
        return CoopTimeline(detailedEvents: detailedEvents, eventTimeframes: eventTimeFrames /*, date: Date() */)
    }
    
    func coopStageID(name: String) -> String {
        guard let stage = CoopStageNames.init(rawValue: name) else { return UUID().uuidString }
        switch stage {
        case .SpawningGrounds:
            return "coop_1"
        case .MaroonersBay:
            return "coop_2"
        case .LostOutpost:
            return "coop_3"
        case .SalmonidSmokeyard:
            return "coop_4"
        case .RuinsOfArkPolaris:
            return "coop_5"
        }
    }
    
    enum CoopStageNames: String {
        case SpawningGrounds = "Spawning Grounds"
        case MaroonersBay = "Marooner's Bay"
        case LostOutpost = "Lost Outpost"
        case SalmonidSmokeyard = "Salmonid Smokeyard"
        case RuinsOfArkPolaris = "Ruins of Ark Polaris"
    }
}

extension ModeAPIResponse {
    
    var gameModeEvent : Splatoon2.GameModeEvent {
        let timeframe = EventTimeframe(startDate: startTime, endDate: endTime)
        let stageA = Stage(id: self.stageA.id, name: self.stageA.name, imageUrl: URL(string: "\(splatnet2ImageHostUrl)\(self.stageA.image)"))
        let stageB = Stage(id: self.stageB.id, name: self.stageB.name, imageUrl: URL(string: "\(splatnet2ImageHostUrl)\(self.stageB.image)"))
        let rule = Splatoon2.GameModeRule(key: self.rule.key, name: self.rule.name)
        let eventId = String("\(id)\(startTime.timeIntervalSinceReferenceDate)\(endTime.timeIntervalSinceReferenceDate)")
        let event = Splatoon2.GameModeEvent(id: eventId, mode: self.gameMode.gameMode, timeframe: timeframe, stages: [stageA, stageB], rule: rule)
        return event
    }
    
}

extension GameModeAPIResponse {
    
    var gameMode : Splatoon2.GameMode {
        let key = self.key == "gachi" ? "ranked" : self.key
        guard let type = Splatoon2.GameModeType(rawValue: key) else { return Splatoon2.GameMode(name: "Game Mode", type: .regular) }
        return Splatoon2.GameMode(name: self.name, type: type)
    }
}
