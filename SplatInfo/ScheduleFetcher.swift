//
//  ScheduleFetcher.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 16.10.20.
//

import Foundation
import Combine

private let splatnet2ImageHostUrl = "https://splatoon2.ink/assets/splatnet"

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
        
        return Splatoon3.Schedule(regular: .init(events: []),
                                  anarchyBattleOpen: .init(events: []),
                                  anarchyBattleSeries: .init(events: []),
                                  league: .init(events: []),
                                  x: .init(events: []),
                                  coop: .init(events: [], otherTimeframes: []),
                                  splatfest: .init(timeline: .init(events: []), fest: nil))
    }
    
    static var example : Splatoon3.Schedule {
        let schedulesPath = Bundle.main.path(forResource: "schedules", ofType: "json")
        guard let schedulesData = try? Data(contentsOf: URL(fileURLWithPath: schedulesPath!)) else { return Splatoon3.Schedule.empty }
        guard let scheduleResponse : Splatoon3InkAPI.SchedulesAPIResponse = Splatoon3InkAPI.shared().parseAPIResponse(data: schedulesData) else { return Splatoon3.Schedule.empty }
        let schedule = scheduleResponse.schedule
        return schedule
    }
    
    static var splatfestFirstHalfExample : Splatoon3.Schedule {
        let schedulesPath = Bundle.main.path(forResource: "schedules-20220924-210001", ofType: "json")
        guard let schedulesData = try? Data(contentsOf: URL(fileURLWithPath: schedulesPath!)) else { return Splatoon3.Schedule.empty }
        guard let scheduleResponse : Splatoon3InkAPI.SchedulesAPIResponse = Splatoon3InkAPI.shared().parseAPIResponse(data: schedulesData) else { return Splatoon3.Schedule.empty }
        let schedule = scheduleResponse.schedule
        return schedule
    }
    
    static var splatfestSecondHalfExample : Splatoon3.Schedule {
        let schedulesPath = Bundle.main.path(forResource: "schedules-20220925-160000", ofType: "json")
        guard let schedulesData = try? Data(contentsOf: URL(fileURLWithPath: schedulesPath!)) else { return Splatoon3.Schedule.empty }
        guard let scheduleResponse : Splatoon3InkAPI.SchedulesAPIResponse = Splatoon3InkAPI.shared().parseAPIResponse(data: schedulesData) else { return Splatoon3.Schedule.empty }
        let schedule = scheduleResponse.schedule
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
        //print("ScheduleFetcher LoadCachedData \(T.self)")
        let filePath = cacheFileURL(filename: filename)
        let fileManager = FileManager.default
        guard let path = filePath, fileManager.fileExists(atPath: path.path) else { return nil }
        guard let data = try? Data(contentsOf: path) else { return nil }
        guard let cache = try? JSONDecoder().decode(TimelineCache<T>.self, from: data) else { return nil }
        return cache
    }
    
    private func cacheData<T:Codable>(cacheData: TimelineCache<T>, filename: String) {
        //print("ScheduleFetcher CacheData \(T.self)")
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
        //NSLog("sharedContainerURL = \(String(describing: sharedContainerURL))")
        guard let sourceURL = cacheFileURL(filename: filename) else { return }
        guard let destinationURL = sharedContainerURL?.appendingPathComponent(filename) else { return }
        try? FileManager().copyItem(at: sourceURL, to: destinationURL)
    }
    
    func fetchSplatoon2Schedule(completion: @escaping (Result<Splatoon2.Schedule, Error>) -> Void) {
        
        // load cache
        if let cachedTimeline = timelineCache.splatoon2, !cachedTimeline.isOutdated {
            //print("Splatoon2 using cached Timeline \(cachedTimeline.date) outdated:\(cachedTimeline.isOutdated)")
            self.splatoon2Schedule = cachedTimeline.schedule
            completion(.success(cachedTimeline.schedule))
            return
        }
        
        // load from disk
        let filename = "schedules.json"
        if let cacheData = loadCachedData(filename: filename, resultType: Splatoon2.Schedule.self), !cacheData.isOutdated {
            //print("Splatoon2 using disk Timeline \(cacheData.date) outdated:\(cacheData.isOutdated)")
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
                        //print("Splatoon2 new Schedule: \(schedule)")

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
//            print("Splatoon3 using cached Timeline \(cachedTimeline.date) outdated:\(cachedTimeline.isOutdated)")
            self.splatoon3Schedule = cachedTimeline.schedule
            completion(.success(cachedTimeline.schedule))
            return
        }
        
        // load from disk
        let filename = "schedules.json"
        if let cacheData = loadCachedData(filename: filename, resultType: Splatoon3.Schedule.self), !cacheData.isOutdated {
//            print("Splatoon3 using disk Timeline \(cacheData.date) outdated:\(cacheData.isOutdated)")
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
            
            let schedule = Splatoon3.Schedule(regular: response.regularTimeline, anarchyBattleOpen: response.anarchyBattleOpenTimeline, anarchyBattleSeries: response.anarchyBattleSeriesTimeline, league: response.leageTimeline, x: response.xTimeline, coop: response.coopTimeline, splatfest: .init(timeline: response.splatfestTimeline, fest: response.splatfest))
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
        let events: [GameModeEvent] = self.data.bankaraSchedules.nodes.map({ $0.gameModeEvents }).flatMap({ $0 })
        return .init(events: events.filter({ $0.mode == .splatoon3(type: .anarchyBattleOpen) }))
    }

    var anarchyBattleSeriesTimeline: GameTimeline {
        let events: [GameModeEvent] = self.data.bankaraSchedules.nodes.map({ $0.gameModeEvents }).flatMap({ $0 })
        return .init(events: events.filter({ $0.mode == .splatoon3(type: .anarchyBattleSeries) }))
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
    
    var splatfest: Splatoon3.Schedule.Splatfest.Fest? {
        return self.data.currentFest?.splatoonKitSplatfest
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

extension Splatoon3InkAPI.SchedulesAPIResponse {
    
    var schedule: Splatoon3.Schedule {
        let schedule = Splatoon3.Schedule(regular: regularTimeline, anarchyBattleOpen: anarchyBattleOpenTimeline, anarchyBattleSeries: anarchyBattleSeriesTimeline, league: leageTimeline, x: xTimeline, coop: coopTimeline, splatfest: .init(timeline: splatfestTimeline, fest: splatfest))
        return schedule
    }
}

extension Splatoon3InkAPI.CurrentFest {
    
    var splatoonKitSplatfest: Splatoon3.Schedule.Splatfest.Fest {
        let timeframe = EventTimeframe(startDate: self.startTime, endDate: self.endTime)
        let teams = self.teams.map({ $0.splattonKitTeam })
        return .init(id: self.id, timeframe: timeframe, midtermTime: self.midtermTime, title: self.title, teams: teams, state: self.state.splattonKitState, tricolorStage: Stage(id: self.tricolorStage.id, name: self.tricolorStage.name, imageUrl: self.tricolorStage.image.url))
    }
}

extension Splatoon3InkAPI.CurrentFest.State {

    var splattonKitState : Splatoon3.Schedule.Splatfest.Fest.State {
        switch self {
        case .scheduled:
            return .scheduled
        case .firstHalf:
            return .firstHalf
        case .secondHalf:
            return .secondHalf
        }
    }
}

extension Splatoon3InkAPI.CurrentFest.Team {

    var splattonKitTeam : Splatoon3.Schedule.Splatfest.Fest.Team {
        return .init(id: self.id, role: self.role.splattonKitRole, color: self.color.splattonKitColor)
    }
}

extension Splatoon3InkAPI.CurrentFest.Team.Role {

    var splattonKitRole : Splatoon3.Schedule.Splatfest.Fest.Team.Role {
        return .init(rawValue: self.rawValue) ?? .attack
    }
}

extension Splatoon3InkAPI.CurrentFest.Team.RGBAColor {

    var splattonKitColor : Splatoon3.Schedule.Splatfest.Fest.Team.RGBAColor {
        return .init(r: r, g: g, b: b, a: a)
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

extension Splatoon3InkAPI.BankaraEvent {
    
    var gameModeEvents: [GameModeEvent] {
        var events: [GameModeEvent] = []
        for setting in self.bankaraMatchSettings ?? [] {
            let event = GameModeEvent(id: UUID().uuidString, mode: .splatoon3(type: setting.mode == .open ? .anarchyBattleOpen : .anarchyBattleSeries), stages: setting.stages, rule: setting.rule, timeframe: EventTimeframe(startDate: self.startTime, endDate: self.endTime))
            events.append(event)
        }
        for setting in self.challengeMatchSettings {
            let event = GameModeEvent(id: UUID().uuidString, mode: .splatoon3(type: setting.mode == .open ? .anarchyBattleOpen : .anarchyBattleSeries), stages: setting.stages, rule: setting.rule, timeframe: EventTimeframe(startDate: self.startTime, endDate: self.endTime))
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
