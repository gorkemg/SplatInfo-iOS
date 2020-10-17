//
//  ScheduleFetcher.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 16.10.20.
//

import Foundation

private let splatnetImageHostUrl = "https://splatoon2.ink/assets/splatnet"

struct Schedule {
    let regular: GameModeTimeline
    let ranked: GameModeTimeline
    let league: GameModeTimeline
    
    static var empty : Schedule {
        return Schedule(regular: GameModeTimeline.empty(.regular), ranked: GameModeTimeline.empty(.ranked), league: GameModeTimeline.empty(.league))
    }
    
    static var example : Schedule {
        let path = Bundle.main.path(forResource: "schedules", ofType: "json")
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path!)) else { return Schedule.empty }
        guard let scheduleResponse : SchedulesAPIResponse = Splatoon2InkAPI.shared().parseAPIResponse(data: data) else { return Schedule.empty }
        return scheduleResponse.schedule
    }
}

class ScheduleFetcher {
    
    private let api = Splatoon2InkAPI.shared()
    
    func fetchSchedules(completion: @escaping (_ schedule: Schedule?, _ error: Error?) -> Void) {
        
        api.requestSchedules { (response, error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let response = response else {
                completion(nil, InvalidResponseError())
                return
            }
            
//            let regularEvents = response.regular.map({ $0.gameModeEvent })
//            let rankedEvents = response.gachi.map({ $0.gameModeEvent })
//            let leagueEvents = response.league.map({ $0.gameModeEvent })
//
//            let regular = GameModeTimeline(modeType: .regular, schedule: regularEvents)
//            let ranked = GameModeTimeline(modeType: .ranked, schedule: rankedEvents)
//            let league = GameModeTimeline(modeType: .league, schedule: leagueEvents)
//            let schedule = Schedule(regular: regular, ranked: ranked, league: league)
            let schedule = response.schedule
            completion(schedule, nil)
        }
    }
}

class InvalidResponseError: Error {
}

extension SchedulesAPIResponse {
    
    var schedule : Schedule {
        let regularEvents = self.regular.map({ $0.gameModeEvent })
        let rankedEvents = self.gachi.map({ $0.gameModeEvent })
        let leagueEvents = self.league.map({ $0.gameModeEvent })
        
        let regular = GameModeTimeline(modeType: .regular, schedule: regularEvents)
        let ranked = GameModeTimeline(modeType: .ranked, schedule: rankedEvents)
        let league = GameModeTimeline(modeType: .league, schedule: leagueEvents)
        let schedule = Schedule(regular: regular, ranked: ranked, league: league)
        return schedule
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
        guard let type = GameModeType.init(rawValue: self.key) else { return GameMode(name: "Regular Battle", type: .regular) }
        return GameMode(name: self.name, type: type)
    }
}
