//
//  NetworkManager.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/6/21.
//

import Foundation
import Combine
import AuthenticationServices

protocol StravaAPICallerProtocol {
    func getAthlete() -> Future<Athlete, Error>
    func getAthleteStats(id: Int) -> Future<ActivityStats, Error>
}

class StravaAPICaller: StravaAPICallerProtocol {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Functions
    
    func getAthleteStats(id: Int) -> Future<ActivityStats, Error> {
        return getData(endpoint: .stats(athleteId: id), type: ActivityStats.self)
    }
    
    func getAthlete() -> Future<Athlete, Error> {
        return getData(endpoint: .athlete, type: Athlete.self)
    }
    
    // MARK: - Private Functions
    
    private func getData<T: Decodable>(endpoint: Endpoint, type: T.Type) -> Future<T, Error> {
        return Future { [weak self] promise in
            // Build URL
            guard let self = self, let url = endpoint.url else {
                return promise(.failure(NetworkError.invalidURL))
            }
            // Make Request
            self.createRequest(with: url, type: .GET) { request in
                URLSession.shared.dataTaskPublisher(for: request)
                    .tryMap { (data, response) -> Data in
                        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                            print("GetData: \(endpoint) Status Code Error")
                            throw NetworkError.responseError
                        }
                        return data
                    }
                
                    .decode(type: T.self, decoder: JSONDecoder())
                    .receive(on: RunLoop.main)
                    .sink(receiveCompletion: { (completion) in
                        if case let .failure(error) = completion {
                            switch error {
                            case let decodingError as DecodingError:
                                print(String(describing: decodingError))
                                promise(.failure(decodingError))
                            case let apiError as NetworkError:
                                promise(.failure(apiError))
                            default:
                                promise(.failure(NetworkError.unknown))
                            }
                        }
                    }, receiveValue: {
                        print("GetData: \(endpoint) Success")
                        promise(.success($0))
                    })
                    .store(in: &self.cancellables)
            }
            
        }
        
    }
    
    private func createRequest(
        with url: URL?,
        type: HTTPMethod,
        completion: @escaping (URLRequest) -> Void
    ) {
        StravaAuthManager.shared.withValidToken { token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
    
    private enum Endpoint {
        case athlete
        case stats(athleteId: Int)
        var url: URL? {
            switch self {
            case .athlete:
                return URL(string: "\(Constants.baseURL)/athlete")
            case .stats(let athleteId):
                return URL(string: "\(Constants.baseURL)/athletes/\(athleteId)/stats")
            }
        }
    }
    
    private enum HTTPMethod: String {
        case GET
        case PUT
        case POST
        case DELETE
    }
}
