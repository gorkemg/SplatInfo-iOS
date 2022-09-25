//
//  ScheduleFetcher.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 16.10.20.
//

import Foundation
import Combine

private let splatnet2ImageHostUrl = "https://splatoon2.ink/assets/splatnet"

//struct Schedule: Codable {
//
//    var timelines: [GameModeTimeline] = []
//
//    struct Splatoon2 {
//
//        var regular:
//
//
//        static var empty : Schedule {
//            return Schedule(timelines: [])
//        }
//
//        static var example : Schedule {
//            let schedulesPath = Bundle.main.path(forResource: "schedules", ofType: "json")
//            guard let schedulesData = try? Data(contentsOf: URL(fileURLWithPath: schedulesPath!)) else { return Schedule.Splatoon2.empty }
//            guard let scheduleResponse : Splatoon2InkAPI.SchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: schedulesData) else { return Schedule.Splatoon2.empty }
//            let coopSchedulesPath = Bundle.main.path(forResource: "coop-schedules", ofType: "json")
//            guard let coopSchedulesData = try? Data(contentsOf: URL(fileURLWithPath: coopSchedulesPath!)) else { return Schedule.Splatoon2.empty }
//            guard let coopScheduleResponse : Splatoon2InkAPI.CoopSchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: coopSchedulesData) else { return Schedule.Splatoon2.empty }
//            let regularTimelines: [GameModeTimeline] = scheduleResponse.gameModeEventTimelines
//            let coopTimeline: GameModeTimeline = coopScheduleResponse.coopTimeline
//            let timelines: [GameModeTimeline] = regularTimelines + [coopTimeline]
//            let schedule = Schedule(timelines: timelines)
//            return schedule
//        }
//
//    }
//
//    func allImageURLs() -> [URL] {
//        var imageURLs : [URL] = []
//        for timeline in timelines {
//            imageURLs.append(contentsOf: timeline.allImageURLs())
//        }
//        return imageURLs
//    }
//}

extension GameTimeline: ImageURLs {
    
    func allImageURLs() -> [URL] {
        return events.compactMap({ $0.allImageURLs() }).flatMap({ $0 })
    }
}

extension Splatoon3.Schedule: ImageURLs {
    
    func allImageURLs() -> [URL] {
        let timelines = [regular, anarchyBattleOpen, anarchyBattleSeries, league, x]
        let timelineURLs = timelines.compactMap({ $0.allImageURLs() }).flatMap({ $0 })
        return timelineURLs + coop.allImageURLs()
    }
    
    static var empty : Splatoon3.Schedule {

        return Splatoon3.Schedule(splatfest: .init(events: []),
                                  regular: .init(events: []),
                                  anarchyBattleOpen: .init(events: []),
                                  anarchyBattleSeries: .init(events: []),
                                  league: .init(events: []),
                                  x: .init(events: []),
                                  coop: .init(events: [], otherTimeframes: []))
    }

    static var example : Splatoon3.Schedule {
        let schedulesPath = Bundle.main.path(forResource: "schedules", ofType: "json")
        guard let schedulesData = try? Data(contentsOf: URL(fileURLWithPath: schedulesPath!)) else { return Splatoon3.Schedule.empty }
        guard let scheduleResponse : Splatoon3InkAPI.SchedulesAPIResponse = Splatoon3InkAPI.shared().parseAPIResponse(data: schedulesData) else { return Splatoon3.Schedule.empty }
        let schedule = Splatoon3.Schedule(splatfest: scheduleResponse.splatfestTimeline, regular: scheduleResponse.regularTimeline, anarchyBattleOpen: scheduleResponse.anarchyBattleOpenTimeline, anarchyBattleSeries: scheduleResponse.anarchyBattleSeriesTimeline, league: scheduleResponse.leageTimeline, x: scheduleResponse.xTimeline, coop: scheduleResponse.coopTimeline)
        return schedule
    }
}

extension Splatoon2.Schedule: ImageURLs {
    
    static var empty : Splatoon2.Schedule {
        return .init(regular: .init(events: []), ranked: .init(events: []), league: .init(events: []), coop: .init(events: [], otherTimeframes: []))
    }
    
    static var example : Splatoon2.Schedule {
        let schedulesPath = Bundle.main.path(forResource: "schedules", ofType: "json")
        guard let schedulesData = try? Data(contentsOf: URL(fileURLWithPath: schedulesPath!)) else { return Splatoon2.Schedule.empty }
        guard let scheduleResponse : Splatoon2InkAPI.SchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: schedulesData) else { return Splatoon2.Schedule.empty }
        let coopSchedulesPath = Bundle.main.path(forResource: "coop-schedules", ofType: "json")
        guard let coopSchedulesData = try? Data(contentsOf: URL(fileURLWithPath: coopSchedulesPath!)) else { return Splatoon2.Schedule.empty }
        guard let coopScheduleResponse : Splatoon2InkAPI.CoopSchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: coopSchedulesData) else { return Splatoon2.Schedule.empty }
        let schedule = Splatoon2.Schedule(regular: .init(events: scheduleResponse.regularTimeline), ranked: .init(events: scheduleResponse.rankedTimeline), league: .init(events: scheduleResponse.leageTimeline), coop: coopScheduleResponse.coopTimeline)
        return schedule
    }
    
    func allImageURLs() -> [URL] {
        var imageURLs : [URL] = []
        for timeline in [regular, ranked, league] {
            imageURLs.append(contentsOf: timeline.allImageURLs())
        }
        imageURLs.append(contentsOf: coop.allImageURLs())
        return imageURLs
    }

}

//struct Splatoon2Schedule: Codable, ImageURLs {
//
//    var regular: [GameModeEvent]
//    var ranked: [GameModeEvent]
//    var league: [GameModeEvent]
//    var coop: CoopTimeline
//
//    static var empty : Splatoon2Schedule {
//        return Splatoon2Schedule(regular: [], ranked: [], league: [], coop: .init(events: [], otherTimeframes: []))
//    }
//
//    static var example : Splatoon2Schedule {
//        let schedulesPath = Bundle.main.path(forResource: "schedules", ofType: "json")
//        guard let schedulesData = try? Data(contentsOf: URL(fileURLWithPath: schedulesPath!)) else { return Splatoon2Schedule.empty }
//        guard let scheduleResponse : Splatoon2InkAPI.SchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: schedulesData) else { return Splatoon2Schedule.empty }
//        let coopSchedulesPath = Bundle.main.path(forResource: "coop-schedules", ofType: "json")
//        guard let coopSchedulesData = try? Data(contentsOf: URL(fileURLWithPath: coopSchedulesPath!)) else { return Splatoon2Schedule.empty }
//        guard let coopScheduleResponse : Splatoon2InkAPI.CoopSchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: coopSchedulesData) else { return Splatoon2Schedule.empty }
////        let schedule = Splatoon2Schedule(timelines: scheduleResponse.gameModeEventTimelines + [coopScheduleResponse.coopTimeline])
//        let schedule = Splatoon2Schedule(regular: scheduleResponse.regularTimeline, ranked: scheduleResponse.rankedTimeline, league: scheduleResponse.leageTimeline, coop: coopScheduleResponse.coopTimeline)
//        return schedule
//    }
//
//    func allImageURLs() -> [URL] {
//        var imageURLs : [URL] = []
//        for timeline in [regular, ranked, league] {
//            imageURLs.append(contentsOf: timeline.allImageURLs())
//        }
//        imageURLs.append(contentsOf: coop.allImageURLs())
//        return imageURLs
//    }
//}

extension GameSchedule {

    func allImageURLs() -> [URL] {
        return self.schedule.allImageURLs()
    }
}

extension ScheduleEvents: ImageURLs {
    func allImageURLs() -> [URL] {
        switch self {
        case .regular(let events):
            return events.compactMap({ $0.allImageURLs() }).flatMap({ $0 })
        case .coop(let events, _):
            return events.compactMap({ $0.allImageURLs() }).flatMap({ $0 })
        }
    }
}

//extension [GameModeEvent]: ImageURLs {
//    func allImageURLs() -> [URL] {
//        return self.compactMap({ $0.allImageURLs() }).flatMap({ $0 })
//    }
//}

extension CoopTimeline: ImageURLs, WeaponImageURLs {
    func allImageURLs() -> [URL] {
        return self.events.compactMap({ $0.allImageURLs() }).flatMap({ $0 })
    }
    
    func allWeaponImageURLs() -> [URL] {
        return self.events.compactMap({ $0.allWeaponImageURLs() }).flatMap({ $0 })
    }
}

extension GameModeEvent: ImageURLs {
    
    func allImageURLs() -> [URL] {
        let imageURLs = self.stages.map({ $0.imageUrl })
        let stageImageURLs = imageURLs.compactMap({ $0 })
        return stageImageURLs
    }
}

extension CoopEvent: ImageURLs, WeaponImageURLs {
    
    func allImageURLs() -> [URL] {
        var imageURLs: [URL] = []
        if let imageUrl = self.stage.imageUrl {
            imageURLs.append(imageUrl)
        }
        return imageURLs
    }
    
    func allWeaponImageURLs() -> [URL] {
        let coopWeaponImageURLs = self.weaponDetails.compactMap { details in
            return details.imageUrl
        }
        return coopWeaponImageURLs.compactMap({ $0 })
    }
}

protocol ImageURLs {
    func allImageURLs() -> [URL]
}

protocol WeaponImageURLs {
    func allWeaponImageURLs() -> [URL]
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
//        let modes = [gameModes.turfWar, gameModes.ranked, gameModes.league]
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

//struct GameModesTimelines: Codable /*, Outdated */ {
//    let regular: Splatoon2.GameModeTimeline
//    let ranked: Splatoon2.GameModeTimeline
//    let league: Splatoon2.GameModeTimeline
////    let date: Date
//
//    static var empty : GameModesTimelines {
//        return GameModesTimelines(regular: Splatoon2.GameModeTimeline.empty(.turfWar), ranked: Splatoon2.GameModeTimeline.empty(.ranked), league: Splatoon2.GameModeTimeline.empty(.league))
//    }
//}

//extension Splatoon2.GameModeTimeline {
//    func allImageURLs() -> [URL] {
//        let stages = self.schedule.flatMap({ $0.stages })
//        let imageURLs = stages.map({ $0.imageUrl })
//        let stageImageURLs = imageURLs.compactMap({ $0 /*URL(string: $0) */ })
//        return stageImageURLs
//    }
//}

//extension CoopTimeline : Outdated {
//    // make CoopTimeline extend Outdated protocol
//}

//extension CoopTimeline {
//    func allImageURLs() -> [URL] {
//        let coopStageImageURLStrings = allStageImageURLs()
//        let coopWeaponImageURLStrings = allWeaponImageURLs()
//        let imageURLs = coopStageImageURLStrings + coopWeaponImageURLStrings
////        let imageURLs = combined.compactMap({ URL(string: $0) })
//        return imageURLs
//    }
//
//    func allStageImageURLs() -> [URL] {
//        let coopStageImageURLStrings = self.detailedEvents.map({ $0.stage.imageUrl })
//        return coopStageImageURLStrings.compactMap({ $0 /*URL(string: $0) */ })
//    }
//
//    func allWeaponImageURLs() -> [URL] {
//        let coopWeaponImageURLs = self.detailedEvents.map({ $0.weapons.map { (weapon) -> URL? in
//            switch weapon {
//            case .weapon(details: let details):
//                return details.imageUrl
//            case .coopSpecialWeapon(details: let details):
//                return details.imageUrl
//            }
//        } }).flatMap({ $0 })
//        return coopWeaponImageURLs.compactMap({ $0 })
//    }
//}

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

class TimelineCacheManager {
    static let shared = TimelineCacheManager()
    private init() {}

    var splatoon2: TimelineCache<Splatoon2.Schedule>?
    var splatoon3: TimelineCache<Splatoon3.Schedule>?
}

struct TimelineCache<T: Codable>: Codable {
    var schedule: T
    let date: Date
    
    var isOutdated : Bool {
        return self.date < Date().addingTimeInterval(-3600) // is stored date older than one hour ago
    }
}


class ScheduleFetcher: ObservableObject {
    
    private let splat2API = Splatoon2InkAPI.shared()
    private let splat3API = Splatoon3InkAPI.shared()
    private let timelineCache = TimelineCacheManager.shared
    var defaultCacheDirectory: String = NSTemporaryDirectory()
    var useSharedFolderForCaching: Bool = false
    
    @Published var splatoon2Schedule : Splatoon2.Schedule = Splatoon2.Schedule.empty
    @Published var splatoon3Schedule : Splatoon3.Schedule = Splatoon3.Schedule.empty

    private func loadCachedData<T>(filename: String, resultType: T.Type) -> TimelineCache<T>? where T:Codable {
        print("ScheduleFetcher LoadCachedData \(self)")
        let filePath = cacheFileURL(filename: filename)
        let fileManager = FileManager.default
        guard let path = filePath, fileManager.fileExists(atPath: path.path) else { return nil }
        guard let data = try? Data(contentsOf: path) else { return nil }
        guard let cache = try? JSONDecoder().decode(TimelineCache<T>.self, from: data) else { return nil }
        return cache
    }
    
    private func cacheData<T:Codable>(cacheData: TimelineCache<T>, filename: String) {
        print("ScheduleFetcher CacheData \(self)")
        let filePath = cacheFileURL(filename: filename)
        guard let path = filePath, let data = try? cacheData.encoded() else { return }
        try? data.write(to: path)
        copyCacheFileToAppGroupDirectory(filename)
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
    
    func fetchSplatoon2Schedule(completion: @escaping (Result<Splatoon2.Schedule, Error>) -> Void) {
        
        // load cache
        if let cachedTimeline = timelineCache.splatoon2, !cachedTimeline.isOutdated {
            print("Using cached Timeline")
            self.splatoon2Schedule = cachedTimeline.schedule
            completion(.success(cachedTimeline.schedule))
            return
        }
        
        // load from disk
        let filename = "schedules.json"
        if let cacheData = loadCachedData(filename: filename, resultType: Splatoon2.Schedule.self), !cacheData.isOutdated {
            self.timelineCache.splatoon2 = cacheData
            self.splatoon2Schedule = cacheData.schedule
            completion(.success(cacheData.schedule))
            return
        }

        // download
        fetchSplatoon2RegularSchedules { [weak self] regularResult in
                        
            switch regularResult {
            case .success(let regularSchedule):

                guard let self = self else { return }
                self.fetchSplatoon2CoopTimeline { [weak self] coopResult in
                    
                    guard let self = self else { return }
                    switch coopResult {
                    case .success(let coopTimeline):
                        
                        let schedule = Splatoon2.Schedule(regular: .init(events: regularSchedule.regular), ranked: .init(events: regularSchedule.ranked), league: .init(events: regularSchedule.league), coop: coopTimeline)
                        let cacheData = TimelineCache(schedule: schedule, date: Date())
                        
                        // store in cache
                        self.timelineCache.splatoon2 = cacheData

                        // store on disk
                        self.cacheData(cacheData: cacheData, filename: filename)

                        // save
                        self.splatoon2Schedule = schedule
                        
                        // return
                        completion(.success(schedule))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                break
            case .failure(let error):
                completion(.failure(error))
                break
            }
        }
    }

    struct FetchSplatoon2RegularSchedulesResult {
        let regular: [GameModeEvent]
        let ranked: [GameModeEvent]
        let league: [GameModeEvent]
    }
    
    private func fetchSplatoon2RegularSchedules(completion: @escaping (Result<FetchSplatoon2RegularSchedulesResult, Error>) -> Void) {
        
        splat2API.requestSchedules { (response, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let response = response else {
                completion(.failure(InvalidResponseError()))
                return
            }

            let result = FetchSplatoon2RegularSchedulesResult(regular: response.regularTimeline, ranked: response.rankedTimeline, league: response.leageTimeline)
            completion(.success(result))
        }
    }
    
    private func fetchSplatoon2CoopTimeline(completion: @escaping (Result<CoopTimeline, Error>) -> Void) {

        splat2API.requestCoopSchedules { (coopResponse, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let coopResponse = coopResponse else {
                completion(.failure(InvalidResponseError()))
                return
            }
            
            let coopTimeline = coopResponse.coopTimeline
            completion(.success(coopTimeline))
        }
    }
    
    // MARK: - Splatoon 3
    
    func fetchSplatoon3Schedule(completion: @escaping (Result<Splatoon3.Schedule, Error>) -> Void) {
        
        // load cache
        if let cachedTimeline = timelineCache.splatoon3, !cachedTimeline.isOutdated {
            print("Using cached Timeline")
            self.splatoon3Schedule = cachedTimeline.schedule
            completion(.success(cachedTimeline.schedule))
            return
        }
        
        // load from disk
        let filename = "schedules.json"
        if let cacheData = loadCachedData(filename: filename, resultType: Splatoon3.Schedule.self), !cacheData.isOutdated {
            self.timelineCache.splatoon3 = cacheData
            self.splatoon3Schedule = cacheData.schedule
            completion(.success(cacheData.schedule))
            return
        }
        
        splat3API.requestSchedules { response, error in

            if let error = error {
                completion(.failure(error))
                return
            }
            guard let response = response else {
                completion(.failure(InvalidResponseError()))
                return
            }
            
            let schedule = Splatoon3.Schedule(splatfest: response.splatfestTimeline, regular: response.regularTimeline, anarchyBattleOpen: response.anarchyBattleOpenTimeline, anarchyBattleSeries: response.anarchyBattleSeriesTimeline, league: response.leageTimeline, x: response.xTimeline, coop: response.coopTimeline)
            self.splatoon3Schedule = schedule
            completion(.success(schedule))
        }

    }

}

class InvalidResponseError: Error {
}

extension Splatoon2InkAPI.SchedulesAPIResponse {

    struct Result {
        var regular: [GameModeEvent]
        var ranked: [GameModeEvent]
        var league: [GameModeEvent]
    }
    
    var regularTimeline: [GameModeEvent] {
        let regularEvents = self.regular.map({ $0.gameModeEvent(mode: .splatoon2(type: .turfWar)) })
        return regularEvents
    }

    var rankedTimeline: [GameModeEvent] {
        let rankedEvents = self.gachi.map({ $0.gameModeEvent(mode: .splatoon2(type: .ranked)) })
        return rankedEvents
    }

    var leageTimeline: [GameModeEvent] {
        let leagueEvents = self.league.map({ $0.gameModeEvent(mode: .splatoon2(type: .league)) })
        return leagueEvents
    }
}

extension Splatoon3InkAPI.SchedulesAPIResponse {

    var regularTimeline: GameTimeline {
        let events = self.data.regularSchedules.nodes.flatMap({ $0.gameModeEvents(mode:.splatoon3(type: .turfWar)) })
        return .init(events: events)
    }

    var anarchyBattleOpenTimeline: GameTimeline {
        let events = self.data.bankaraSchedules.nodes.filter({ ($0.bankaraMatchSettings ?? []).filter({ $0.mode == .open }).count > 0 }).flatMap({ $0.gameModeEvents(mode:.splatoon3(type: .anarchyBattleOpen)) })
        return .init(events: events)
    }

    var anarchyBattleSeriesTimeline: GameTimeline {
        let events = self.data.bankaraSchedules.nodes.filter({ ($0.bankaraMatchSettings ?? []).filter({ $0.mode == .challenge }).count > 0 }).flatMap({ $0.gameModeEvents(mode:.splatoon3(type: .anarchyBattleSeries)) })
        return .init(events: events)
    }

    var leageTimeline: GameTimeline {
        let events = self.data.leagueSchedules.nodes.flatMap({ $0.gameModeEvents(mode:.splatoon3(type: .league)) })
        return .init(events: events)
    }

    var xTimeline: GameTimeline {
        let events = self.data.xSchedules.nodes.flatMap({ $0.gameModeEvents(mode:.splatoon3(type: .x)) })
        return .init(events: events)
    }

    var coopTimeline: CoopTimeline {
        return .init(events: coopEvents, otherTimeframes: [])
    }
    
    var splatfestTimeline: GameTimeline {
        let events = self.data.festSchedules.nodes.flatMap({ $0.gameModeEvents(mode: .splatoon3(type: .turfWar)) })
        return .init(events: events)
    }
    
    var coopEvents: [CoopEvent] {
        
        var events: [CoopEvent] = []
        let coopEvents = self.data.coopGroupingSchedule.regularSchedules.nodes
        for event in coopEvents {
            let coopEvent = CoopEvent(timeframe: EventTimeframe(startDate: event.startTime, endDate: event.endTime), weapons: event.setting.weapons.map({ $0.weapon }), stage: Stage(id: event.setting.coopStage.id, name: event.setting.coopStage.name, imageUrl: event.setting.coopStage.image.url))
            events.append(coopEvent)
        }
        return events
    }
    
}

extension Splatoon3InkAPI.Weapon {
    
    var weapon: Weapon {
        return .weapon(details: WeaponDetails(id: UUID().uuidString, name: self.name, imageUrl: self.image.url))
    }
    
}

extension Decodable where Self: EventDetails {
    
    func gameModeEvents(mode: GameModeType) -> [GameModeEvent] {
        var events: [GameModeEvent] = []
        for setting in matchSetting {
            let event = GameModeEvent(id: UUID().uuidString, mode: mode, stages: setting.stages, rule: setting.rule, timeframe: EventTimeframe(startDate: self.startTime, endDate: self.endTime))
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
    
    var rule: GameModeRule {
        return .init(rawValue: self.vsRule.rule.rawValue) ?? .turfWar
    }
}

extension Splatoon2InkAPI.CoopSchedulesAPIResponse {
    
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
        return .init(events: detailedEvents, otherTimeframes: eventTimeFrames)
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

extension Splatoon2InkAPI.ModeAPIResponse {
    
    func gameModeEvent(mode: GameModeType) -> GameModeEvent {
        let timeframe = EventTimeframe(startDate: startTime, endDate: endTime)
        let stageA = Stage(id: self.stageA.id, name: self.stageA.name, imageUrl: URL(string: "\(splatnet2ImageHostUrl)\(self.stageA.image)"))
        let stageB = Stage(id: self.stageB.id, name: self.stageB.name, imageUrl: URL(string: "\(splatnet2ImageHostUrl)\(self.stageB.image)"))
        let eventId = String("\(id)\(startTime.timeIntervalSinceReferenceDate)\(endTime.timeIntervalSinceReferenceDate)")
        let mode: GameModeType = .splatoon2(type: self.gameMode.mode)
        let event = GameModeEvent(id: eventId, mode: mode, stages: [stageA, stageB], rule: self.rule.gameModeRule, timeframe: timeframe)
        return event
    }
    
}

extension Splatoon2InkAPI.GameModeAPIResponse {
    
    var mode : Splatoon2.GameModeType {
        print("GameModeType: \(self.key)")
        switch self.key {
        case .regular:
            return .turfWar
        case .ranked:
            return .ranked
        case .league:
            return .league
        case .coop:
            return .salmonRun
        }
    }
}

extension Splatoon2InkAPI.RuleAPIResponse {
    
    var gameModeRule: GameModeRule {
        print("GameModeRule: \(self.key)")
        switch self.key {
        case .turfWar:
            return .turfWar
        case .splatZones:
            return .splatZones
        case .towerControl:
            return .towerControl
        case .rainmaker:
            return .rainmaker
        case .clamBlitz:
            return .clamBlitz
        }
    }
    
}
