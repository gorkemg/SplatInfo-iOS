//
//  ScheduleFetcher.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 16.10.20.
//

import Foundation
import Combine

private let splatnetImageHostUrl = "https://splatoon2.ink/assets/splatnet"

struct Schedule: Codable {
    var gameModes = GameModesTimelines.empty
    var coop = CoopTimeline.empty()
    
    static var empty : Schedule {
        return Schedule(gameModes: GameModesTimelines.empty, coop: CoopTimeline.empty())
    }
    
    static var example : Schedule {
        let schedulesPath = Bundle.main.path(forResource: "schedules", ofType: "json")
        guard let schedulesData = try? Data(contentsOf: URL(fileURLWithPath: schedulesPath!)) else { return Schedule.empty }
        guard let scheduleResponse : SchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: schedulesData) else { return Schedule.empty }
        let coopSchedulesPath = Bundle.main.path(forResource: "coop-schedules", ofType: "json")
        guard let coopSchedulesData = try? Data(contentsOf: URL(fileURLWithPath: coopSchedulesPath!)) else { return Schedule.empty }
        guard let coopScheduleResponse : CoopSchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: coopSchedulesData) else { return Schedule.empty }
        let schedule = Schedule(gameModes: scheduleResponse.gameModesTimelines, coop: coopScheduleResponse.coopTimeline)
        return schedule
    }
}

protocol Outdated {

    var date : Date { get }
    var isOutdated : Bool { get }
}

extension Outdated {

    var isOutdated : Bool {
        return self.date < Date().addingTimeInterval(-3600) // is stored date older than one hour ago
    }
}

struct GameModesTimelines: Codable, Outdated {
    let regular: GameModeTimeline
    let ranked: GameModeTimeline
    let league: GameModeTimeline
    let date: Date

    static var empty : GameModesTimelines {
        return GameModesTimelines(regular: GameModeTimeline.empty(.regular), ranked: GameModeTimeline.empty(.ranked), league: GameModeTimeline.empty(.league), date: Date())
    }
}

extension CoopTimeline : Outdated {
    // make CoopTimeline extend Outdated protocol
}

extension Encodable {
    func toJSONData() -> Data? { try? JSONEncoder().encode(self) }
}

class ScheduleFetcher: ObservableObject {
    
    private let api = Splatoon2InkAPI.shared()
    
    @Published var schedule : Schedule = Schedule.empty
    
    func loadCachedData<T>(filename: String, resultType: T.Type) -> T? where T:Codable {
        let filePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        let fileManager = FileManager.default
        if let path = filePath, fileManager.fileExists(atPath: path.path) {
            if let data = try? Data(contentsOf: path) {
                let decodedObject = try? JSONDecoder().decode(T.self, from: data)
                return decodedObject
            }
        }
        return nil
    }
    
    func cacheData<T:Encodable>(data: T, filename: String) {
        let filePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        if let path = filePath, let data = data.toJSONData() {
            try? data.write(to: path)
        }
    }
    
    func fetchGameModeTimelines(completion: @escaping (_ timelines: GameModesTimelines?, _ error: Error?) -> Void) {
        
        let filename = "schedules.json"
        if let timelines = loadCachedData(filename: filename, resultType: GameModesTimelines.self), !timelines.isOutdated {
            self.schedule.gameModes = timelines
            completion(timelines, nil)
            return
        }
        
        api.requestSchedules { [weak self] (response, error) in
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
            self.cacheData(data: gameModesTimelines, filename: filename)
            self.schedule.gameModes = gameModesTimelines
            completion(gameModesTimelines, nil)
        }
    }
    
    func fetchCoopTimeline(completion: @escaping (_ timeline: CoopTimeline?, _ error: Error?) -> Void) {

        let filename = "coop-schedules.json"
        if let timeline = loadCachedData(filename: filename, resultType: CoopTimeline.self), !timeline.isOutdated {
            self.schedule.coop = timeline
            completion(timeline, nil)
            return
        }

        api.requestCoopSchedules { [weak self] (coopResponse, error) in
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
            self.cacheData(data: coopTimeline, filename: filename)
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
        
        let regular = GameModeTimeline(modeType: .regular, schedule: regularEvents)
        let ranked = GameModeTimeline(modeType: .ranked, schedule: rankedEvents)
        let league = GameModeTimeline(modeType: .league, schedule: leagueEvents)
        let schedule = GameModesTimelines(regular: regular, ranked: ranked, league: league, date: Date())
        return schedule
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
                    let details = WeaponDetails(id: weaponDetails.id, name: weaponDetails.name, imageUrl: "\(splatnetImageHostUrl)\(weaponDetails.image)")
                    let weapon = Weapon.weapon(details: details)
                    weapons.append(weapon)
                }else if let coopWeaponDetails = weaponDetails.coopSpecialWeapon {
                    let details = WeaponDetails(id: UUID().uuidString, name: coopWeaponDetails.name, imageUrl: "\(splatnetImageHostUrl)\(coopWeaponDetails.image)")
                    let weapon = Weapon.weapon(details: details)
                    weapons.append(weapon)
                }
            }
            let stage = Stage(id: UUID().uuidString, name: event.stage.name, imageUrl: "\(splatnetImageHostUrl)\(event.stage.image)")
            let eventDetails = CoopEvent(timeframe: timeframe, weapons: weapons, stage: stage)
            detailedEvents.append(eventDetails)
        }
        var eventTimeFrames : [EventTimeframe] = []
        for otherEvent in self.schedules {
            let timeframe = EventTimeframe(startDate: otherEvent.startTime, endDate: otherEvent.endTime)
            eventTimeFrames.append(timeframe)
        }
        return CoopTimeline(detailedEvents: detailedEvents, eventTimeframes: eventTimeFrames, date: Date())
    }
}

extension ModeAPIResponse {
    
    var gameModeEvent : GameModeEvent {
        let timeframe = EventTimeframe(startDate: startTime, endDate: endTime)
        let stageA = Stage(id: self.stageA.id, name: self.stageA.name, imageUrl: "\(splatnetImageHostUrl)\(self.stageA.image)")
        let stageB = Stage(id: self.stageB.id, name: self.stageB.name, imageUrl: "\(splatnetImageHostUrl)\(self.stageB.image)")
        let rule = GameModeRule(key: self.rule.key, name: self.rule.name)
        let event = GameModeEvent(id: String(id), mode: self.gameMode.gameMode, timeframe: timeframe, stages: [stageA, stageB], rule: rule)
        return event
    }
    
}

extension GameModeAPIResponse {
    
    var gameMode : GameMode {
        let key = self.key == "gachi" ? "ranked" : self.key
        guard let type = GameModeType.init(rawValue: key) else { return GameMode(name: "Game Mode", type: .regular) }
        return GameMode(name: self.name, type: type)
    }
}
