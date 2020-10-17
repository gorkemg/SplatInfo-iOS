//
//  Splatoon2InkAPI.swift
//  SplatInfo
//
//  Created by Görkem Güclü on 15.10.20.
//

import Foundation

class Splatoon2InkAPI {
    
    let apiURL = "https://splatoon2.ink/data"
    
    private static let sharedAPI = Splatoon2InkAPI()

    static func shared() -> Splatoon2InkAPI {
        return sharedAPI
    }
    
    func requestSchedules(completion: @escaping (_ response: SchedulesAPIResponse?, _ error: Error?)->Void) {
        let urlString = "\(apiURL)/schedules.json"
        guard let url = URL(string: urlString) else { completion(nil, InvalidAPIRequestURLError()); return }
        requestAPIAndParse(url: url, completion: completion)
    }

    func requestCoopSchedules(completion: @escaping (_ response: CoopSchedulesAPIResponse?, _ error: Error?)->Void) {
        let urlString = "\(apiURL)/coop-schedules.json"
        guard let url = URL(string: urlString) else { completion(nil, InvalidAPIRequestURLError()); return }
        requestAPIAndParse(url: url, completion: completion)
    }

    func requestMerchandise(completion: @escaping (_ response: MerchandiseAPIResponse?, _ error: Error?)->Void) {
        let urlString = "\(apiURL)/merchandises.json"
        guard let url = URL(string: urlString) else { completion(nil, InvalidAPIRequestURLError()); return }
        requestAPIAndParse(url: url, completion: completion)
    }

    func requestSplatfests(completion: @escaping (_ response: SplatfestsAPIResponse?, _ error: Error?)->Void) {
        let urlString = "\(apiURL)/festivals.json"
        guard let url = URL(string: urlString) else { completion(nil, InvalidAPIRequestURLError()); return }
        requestAPIAndParse(url: url, completion: completion)
    }

    func requestSplatfestRankings(region: SplatfestRegion, festivalId: String, completion: @escaping (_ response: SplatfestRankingsAPIResponse?, _ error: Error?)->Void) {
        let urlString = "\(apiURL)/festivals/\(region.rawValue)-\(festivalId)-rankings.json"
        guard let url = URL(string: urlString) else { completion(nil, InvalidAPIRequestURLError()); return }
        requestAPIAndParse(url: url, completion: completion)
    }

    func requestWeaponsTimeline(completion: @escaping (_ response: WeaponsTimelineAPIResponse?, _ error: Error?)->Void) {
        let urlString = "\(apiURL)/timeline.json"
        guard let url = URL(string: urlString) else { completion(nil, InvalidAPIRequestURLError()); return }
        requestAPIAndParse(url: url, completion: completion)
    }

    func requestLocale(_ locale: LocaleType, completion: @escaping (_ response: LocaleAPIResponse?, _ error: Error?)->Void) {
        let urlString = "\(apiURL)/locale/\(locale.rawValue).json"
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
        jsonDecoder.dateDecodingStrategy = .secondsSince1970
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

}

class InvalidAPIRequestURLError: Error {
}

class InvalidAPIResponseError: Error {
}

enum LocaleType: String {
    case en
    case es
    case es_MX
    case fr
    case fr_CA
    case de
    case nl
    case it
    case ru
    case ja
}

enum SplatfestRegion: String {
    case na
    case eu
    case ja
}

enum APIResponse: Codable {
    case schedules(response: SchedulesAPIResponse)
    case coopSchedules(response: CoopSchedulesAPIResponse)
    case merchandise(response: MerchandiseAPIResponse)
    case splatfests(response: SplatfestsAPIResponse)
    case splatfestRankings(response: SplatfestsAPIResponse)
    case weaponsTimeline(response: WeaponsTimelineAPIResponse)
    case locale(response: LocaleAPIResponse)
    
    enum APIResponseKeys: CodingKey {
        case schedules
        case coopSchedules
        case merchandise
        case splatfests
        case splatfestRankings
        case weaponsTimeline
        case locale
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: APIResponseKeys.self)
        switch self {
        case .schedules(let response):
            try container.encode(response, forKey: .schedules)
        case .coopSchedules(response: let response):
            try container.encode(response, forKey: .coopSchedules)
        case .merchandise(response: let response):
            try container.encode(response, forKey: .merchandise)
        case .splatfests(response: let response):
            try container.encode(response, forKey: .splatfests)
        case .weaponsTimeline(response: let response):
            try container.encode(response, forKey: .weaponsTimeline)
        case .locale(response: let response):
            try container.encode(response, forKey: .locale)
        case .splatfestRankings(response: let response):
            try container.encode(response, forKey: .splatfestRankings)
        }
    }
    
    init(from decoder: Decoder) throws {

        let container = try decoder.singleValueContainer()
        if let response = try? container.decode(SchedulesAPIResponse.self) {
            self = .schedules(response: response)
            return
        }else {
            do {
                let response = try container.decode(CoopSchedulesAPIResponse.self)
                self = .coopSchedules(response: response)
                return
            } catch {
                print("Error: \(error)")
            }
            
            do {
                let response = try container.decode(WeaponsTimelineAPIResponse.self)
                self = .weaponsTimeline(response: response)
                return
            } catch {
                print("Error: \(error)")
            }

            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Unable to decode APIResponse enum"))
        }
    }

}

struct SchedulesAPIResponse: Codable {
    let regular: [ModeAPIResponse]
    let gachi: [ModeAPIResponse]
    let league: [ModeAPIResponse]
}

struct ModeAPIResponse: Codable {
    let id : Int
    let stageA: StageAPIResponse
    let stageB: StageAPIResponse
    let startTime: Date
    let endTime: Date
    let gameMode: GameModeAPIResponse
    let rule: RuleAPIResponse
}

struct StageAPIResponse: Codable {
    let id : String
    let name: String
    let image: String
}

struct GameModeAPIResponse: Codable {
    let key: String
    let name: String
}
struct RuleAPIResponse: Codable {
    let key: String
    let name: String
}

struct CoopSchedulesAPIResponse: Codable {
    let details: [CoopDetailsAPIResponse]
    let schedules: [StartEndAPIResponse]
}

struct CoopDetailsAPIResponse: Codable {
    let startTime: Date
    let endTime: Date
    let weapons: [CoopWeaponAPIResponse]
    let stage: CoopStageAPIResponse
}

struct CoopStageAPIResponse: Codable {
    let name: String
    let image: String
}

struct StartEndAPIResponse: Codable {
    let startTime: Date
    let endTime: Date
}

struct CoopWeaponAPIResponse: Codable {
    let id: String
    let weapon: WeaponAPIResponse?
    let coopSpecialWeapon: SpecialWeaponAPIResponse?
}

struct WeaponAPIResponse: Codable {
    let id: String
    let image: String
    let name: String
}

struct SpecialWeaponAPIResponse: Codable {
    let name: String
    let image: String
}

struct MerchandiseAPIResponse: Codable {
}

struct SplatfestsAPIResponse: Codable {
    
}

struct SplatfestRankingsAPIResponse: Codable {
    
}

struct WeaponsTimelineAPIResponse: Codable {
    let coop: CoopWeaponsTimelineAPIResponse?
}

struct CoopWeaponsTimelineAPIResponse: Codable {
    let importance: Double
    let rewardGear: RewardGearAPIResponse
    let schedule: CoopDetailsAPIResponse
}

struct RewardGearAPIResponse: Codable {
    let availableTime: Date
    let gear: GearAPIResponse
}

struct GearAPIResponse: Codable {
    let id: String
    let name: String
    let image: String
    let kind: String
    let brand: GearBrandAPIResponse
    let rarity: Int
}

struct GearBrandAPIResponse: Codable {
    let id: String
    let name: String
    let image: String
}

struct LocaleAPIResponse: Codable {
    
}
