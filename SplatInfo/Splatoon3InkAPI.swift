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

    func requestCoop(completion: @escaping (_ response: CoopAPIResponse?, _ error: Error?)->Void) {
        let urlString = "\(apiURL)/coop.json"
        guard let url = URL(string: urlString) else { completion(nil, InvalidAPIRequestURLError()); return }
        requestAPIAndParse(url: url, keyDecodingStrategy: .useDefaultKeys, completion: completion)
    }

    func requestFestivals(completion: @escaping (_ response: FestivalsAPIResponse?, _ error: Error?)->Void) {
        let urlString = "\(apiURL)/festivals.json"
        guard let url = URL(string: urlString) else { completion(nil, InvalidAPIRequestURLError()); return }
        requestAPIAndParse(url: url, completion: completion)
    }

    /// Convenience method
    /// Requests data from the API, parses it and returns the appropriate response
    /// - Parameters:
    ///   - url: endpoint to fetch data from
    ///   - completion: completion is called when the response is received
    func requestAPIAndParse<T:Decodable>(url: URL, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase, completion: @escaping (_ response: T?, _ error: Error?)->Void) {
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

                guard let parsedResult : T = self.parseAPIResponse(data: data, keyDecodingStrategy: keyDecodingStrategy) else {
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
    func parseAPIResponse<T:Decodable>(data: Data, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase) -> T? {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        jsonDecoder.keyDecodingStrategy = keyDecodingStrategy
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

            guard (try? JSONSerialization.jsonObject(with: data, options: [])) != nil else {
                let string = String(data: data, encoding: .utf8)
                print("Failed JSON String: \(String(describing: string))")
                completion(nil, nil, InvalidAPIResponseError())
                return
            }
//            print("response JSON: \(String(describing: responseJSON))")
            
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
        let currentFest: Splatfest?
        let vsStages: StageNodes
    }
    
    struct Splatfest: Codable {
        let id: String
        let startTime: Date
        let endTime: Date
        let midtermTime: Date?
        let title: String
        let teams: [Team]
        let state: State
        let tricolorStage: TricolorStage?
        
        let image: ImageURL?
        let lang: String?
        let preVotes: Votes?
        let votes: Votes?

        struct Votes: Codable {
            let totalCount: Int
        }

        struct Team: Codable {
            let id: String
            let role: Role?
            let color: RGBAColor
            
            enum Role: String, Codable {
                case attack = "ATTACK"
                case defense = "DEFENSE"
            }
            
            struct RGBAColor: Codable {
                let r: Float
                let g: Float
                let b: Float
                let a: Float
            }
        }
        
        enum State: String, Codable {
            case scheduled = "SCHEDULED"
            case firstHalf = "FIRST_HALF"
            case secondHalf = "SECOND_HALF"
            case closed = "CLOSED"
        }
        
        struct TricolorStage: Codable {
            let id: String
            let name: String
            let image: ImageURL
        }
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
        let bannerImage: ImageURL?
        let bigRunSchedules: CoopScheduleNodes?
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
        
        var openMatchSettings: [ModeMatchSettings] {
            return bankaraMatchSettings?.filter({ $0.mode == .open }) ?? []
        }
        var challengeMatchSettings: [ModeMatchSettings] {
            return bankaraMatchSettings?.filter({ $0.mode == .challenge }) ?? []
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
        let coopStageId: Int?
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
        let vsStageId: Int
        let id: String
        let originalImage: ImageURL
        let name: String
//        let stats: String?
    }
    
    struct ImageURL: Codable {
        let url: URL
    }
    
    struct CoopAPIResponse: Codable {
        let data: CoopData
        
        struct CoopData: Codable {
            let coopResult: CoopResult
            
            struct CoopResult: Codable {
                let monthlyGear: MonthlyGear
                
                struct MonthlyGear: Codable {
                    let id: String
                    let typeName: String
                    let name: String
                    let image: ImageURL
                    
                    enum CodingKeys: String, CodingKey {
                        case id = "__splatoon3ink_id"
                        case typeName = "__typename"
                        case name
                        case image
                    }
                }
            }
        }
    }

    struct FestivalsAPIResponse: Codable {
        let US: FestivalData
        let EU: FestivalData
        let JP: FestivalData
        let AP: FestivalData
    }
    
    struct FestivalData: Codable {
        let data: FestRecords
    }
    struct FestRecords: Codable {
        let festRecords: FestRecordNodes
    }
    struct FestRecordNodes: Codable {
        let nodes: [Splatfest]
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
