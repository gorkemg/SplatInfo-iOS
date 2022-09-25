//
//  Splatoon3InkAPI.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 17.09.22.
//

import Foundation

class Splatoon3InkAPI {
    
    let apiURL = "https://splatoon3.ink/data"

    private static let sharedAPI = Splatoon3InkAPI()

    static func shared() -> Splatoon3InkAPI {
        return sharedAPI
    }

    func requestSchedules(completion: @escaping (_ response: SchedulesAPIResponse?, _ error: Error?)->Void) {
        let urlString = "\(apiURL)/schedules.json"
        guard let url = URL(string: urlString) else { completion(nil, InvalidAPIRequestURLError()); return }
        requestAPIAndParse(url: url, completion: completion)
    }

    /// Convenience method
    /// Requests data from the API, parses it and returns the appropriate response
    /// - Parameters:
    ///   - url: endpoint to fetch data from
    ///   - completion: completion is called when the response is received
    func requestAPIAndParse<T:Decodable>(url: URL, completion: @escaping (_ response: T?, _ error: Error?)->Void) {
        requestAPI(url: url) { (response, data, error) in

            OperationQueue.main.addOperation {

                if error != nil {
                    completion(nil, InvalidAPIResponseError())
                    return
                }
                
                guard let data = data else {
                    completion(nil, InvalidAPIResponseError())
                    return
                }

                guard let parsedResult : T = self.parseAPIResponse(data: data) else {
                    completion(nil, InvalidAPIResponseError())
                    return
                }
                completion(parsedResult, nil)
            }
        }
    }
    
    /// Parses response data
    /// - Parameters:
    ///   - data: data received from the API
    ///   - completion: completion is called when the response is received
    func parseAPIResponse<T:Decodable>(data: Data) -> T? {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let apiResponse = try jsonDecoder.decode(T.self, from: data)
            return apiResponse
        }catch {
            print("error: \(error)")
        }
        return nil
    }

    
    /// Sends a request to the OpenWeatherMapAPI to fetch data.
    /// - Parameters:
    ///   - url: endpoint to fetch data from
    ///   - completion: completion is called when the response is received
    func requestAPI(url: URL, completion: @escaping (_ response: URLResponse?, _ result: Data?, _ error: Error?)->()) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(nil, nil, error)
                return
            }
            if let error = error {
                print("Error \(error.localizedDescription)")
                completion(nil, nil, error)
                return
            }

            guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) else {
                let string = String(data: data, encoding: .utf8)
                print("Failed JSON String: \(String(describing: string))")
                completion(nil, nil, InvalidAPIResponseError())
                return
            }
            print("response JSON: \(String(describing: responseJSON))")
            
            completion(response, data, nil)
        }
        task.resume()
    }

    struct SchedulesAPIResponse: Codable {
        let data: Schedules
    }
    
    struct Schedules: Codable {
        let regularSchedules: RegularScheduleNodes
        let bankaraSchedules: BankaraScheduleNodes
        let xSchedules: XScheduleNodes
        let leagueSchedules: LeagueScheduleNodes
        let coopGroupingSchedule: CoopGroupingSchedule
        let festSchedules: FestScheduleNodes
//        let currentFest: String?
        let vsStages: StageNodes
    }
    
    /// Turf War
    struct RegularScheduleNodes: Codable {
        let nodes: [RegularEvent]
    }
    /// Anarchy Battle [Series and Open]
    struct BankaraScheduleNodes: Codable {
        let nodes: [BankaraEvent]
    }
    /// X Rank
    struct XScheduleNodes: Codable {
        let nodes: [XEvent]
    }
    /// League
    struct LeagueScheduleNodes: Codable {
        let nodes: [LeagueEvent]
    }
    /// Salmon Run
    struct CoopGroupingSchedule: Codable {
        let regularSchedules: CoopScheduleNodes
//        let bigRunSchedules: [Schedule]
    }
    /// Splatfest
    struct FestScheduleNodes: Codable {
        let nodes: [FestEvent]
    }

    // MARK: - Regular
    
    struct RegularEvent: Codable, EventDetails {
        var startTime: Date
        var endTime: Date
        let regularMatchSetting: MatchSettings?

        var matchSetting: [MatchSetting] {
            guard let setting = regularMatchSetting else { return [] }
            return [setting]
        }
    }
    
    struct MatchSettings: Codable, MatchSetting {
        var __isVsSetting: String
        var __typename: String
        var vsStages: [VsStage]
        var vsRule: VsRule
    }

    // MARK: - X
    
    struct XEvent: Codable, EventDetails {
        var startTime: Date
        var endTime: Date
        let xMatchSetting: MatchSettings?

        var matchSetting: [MatchSetting] {
            guard let setting = xMatchSetting else { return [] }
            return [setting]
        }
    }
    
    // MARK: - League
    
    struct LeagueEvent: Codable, EventDetails {
        var startTime: Date
        var endTime: Date
        let leagueMatchSetting: MatchSettings?

        var matchSetting: [MatchSetting] {
            guard let setting = leagueMatchSetting else { return [] }
            return [setting]
        }
    }
    
    // MARK: - Splatfest
    struct FestEvent: Codable, EventDetails {
        var startTime: Date
        var endTime: Date
        let festMatchSetting: MatchSettings?

        var matchSetting: [MatchSetting] {
            guard let setting = festMatchSetting else { return [] }
            return [setting]
        }
    }

    
    // MARK: - Bankara
    struct BankaraEvent: Codable, EventDetails {
        var startTime: Date
        var endTime: Date
        let bankaraMatchSettings: [ModeMatchSettings]?

        var matchSetting: [MatchSetting] {
            return bankaraMatchSettings ?? []
        }
    }

    struct ModeMatchSettings: Codable, MatchSetting {
        var __typename: String
        var __isVsSetting: String
        var vsStages: [VsStage]
        var vsRule: VsRule
        let mode: VsMode
    }
    
    // MARK: -
    struct VsStage: Codable {
        let id: String
        let vsStageId: Int
        let name: String
        let image: ImageURL
    }
    
    struct VsRule: Codable {
        let name: String
        let rule: VsRuleType
        let id: String
    }
    
    enum VsRuleType: String, Codable {
        case turf = "TURF_WAR"  // Turf War
        case area = "AREA"  // Zones
        case loft = "LOFT"  // Tower
        case goal = "GOAL"  // Rainmaker
        case clam = "CLAM"  // Clam Blitz
    }
    
    enum VsMode: String, Codable {
        case challenge = "CHALLENGE"
        case open = "OPEN"
    }
    
    // MARK: - Coop
    struct CoopScheduleNodes: Codable {
        let nodes: [CoopEvent]
    }
    
    struct CoopEvent: Codable, EventDates {
        var startTime: Date
        var endTime: Date
        let setting: CoopSetting
    }
    
    struct CoopSetting: Codable {
        let __typename: String
        let coopStage: CoopStage
        let weapons: [Weapon]
    }
    
    struct CoopStage: Codable {
        let name: String
        let coopStageId: Int
        let thumbnailImage: ImageURL
        let image: ImageURL
        let id: String
    }
    
    struct Weapon: Codable {
        let name: String
        let image: ImageURL
    }
    
    struct StageNodes: Codable {
        let nodes: [Stage]
    }
    
    struct Stage: Codable {
        let stageId: Int
        let id: String
        let originalImage: ImageURL
        let name: String
//        let stats: String?
    }
    
    struct ImageURL: Codable {
        let url: URL
    }
    
}


protocol EventDates {
    var startTime: Date  { get }
    var endTime: Date { get }
}

protocol MatchSetting {
    var __isVsSetting: String  { get }
    var __typename: String  { get }
    var vsStages: [Splatoon3InkAPI.VsStage]  { get }
    var vsRule: Splatoon3InkAPI.VsRule  { get }
}

protocol EventMatchSettings {
    var matchSetting: [MatchSetting] { get }
}

typealias EventDetails = EventMatchSettings & EventDates
