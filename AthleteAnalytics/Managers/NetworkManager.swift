//
//  NetworkManager.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/6/21.
//

import Foundation
import Combine
import AuthenticationServices

class NetworkManager {
    static let shared = NetworkManager()
    private var cancellables = Set<AnyCancellable>()

    private init() {
        
    }

    
    func getAthlete() -> Future<Athlete, Error> {
        return Future { [weak self] promise in
            // Build URL
            guard let self = self, let url = URL(string: "\(Constants.baseURL)\(StravaAuthManager.shared.athlete!.id)") else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            let token = "Bearer \(StravaAuthManager.shared.accessToken)"
            var request = URLRequest(url: url, timeoutInterval: Double.infinity)
            request.addValue(token, forHTTPHeaderField: "Authorization")

            request.httpMethod = "GET"
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw NetworkError.responseError
                    }
                    return data
                }
                .decode(type: Athlete.self, decoder: JSONDecoder())
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
                }, receiveValue: { promise(.success($0)) })
                .store(in: &self.cancellables)
            
        }
        
    }
}

enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        }
    }
}
