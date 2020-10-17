//
//  ScheduleFetcher.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 16.10.20.
//

import Foundation
import Combine

private let splatnetImageHostUrl = "https://splatoon2.ink/assets/splatnet"

struct Schedule {
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

struct GameModesTimelines {
    let regular: GameModeTimeline
    let ranked: GameModeTimeline
    let league: GameModeTimeline

    static var empty : GameModesTimelines {
        return GameModesTimelines(regular: GameModeTimeline.empty(.regular), ranked: GameModeTimeline.empty(.ranked), league: GameModeTimeline.empty(.league))
    }
}

class ScheduleFetcher: ObservableObject {
    
    private let api = Splatoon2InkAPI.shared()
    
    @Published var schedule : Schedule = Schedule.empty
    
    func fetchGameModeTimelines(completion: @escaping (_ schedule: GameModesTimelines?, _ error: Error?) -> Void) {
        
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
            self.schedule.gameModes = gameModesTimelines
            completion(gameModesTimelines, nil)
        }
    }
    
    func fetchCoopTimeline(completion: @escaping (_ schedule: CoopTimeline?, _ error: Error?) -> Void) {
                
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
        let schedule = GameModesTimelines(regular: regular, ranked: ranked, league: league)
        return schedule
    }
}

extension CoopSchedulesAPIResponse {
    
    var coopTimeline : CoopTimeline {
        return CoopTimeline(detailedSchedules: [], otherSchedules: [])
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
