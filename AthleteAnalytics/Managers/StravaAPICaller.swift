//
//  NetworkManager.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/6/21.
//

import Foundation
import Combine
import AuthenticationServices

class StravaAPICaller {
    static let shared = StravaAPICaller()
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    // MARK: - Public API Calls
    
    public func getAthlete() -> Future<Athlete, Error> {

        return Future { [weak self] promise in
            // Build URL
            guard let self = self, let url = URL(string: "\(Constants.baseURL)\(Constants.authenticatedAthlete)") else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            // Make Request
            self.createRequest(with: url, type: .GET) { request in
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
    // MARK: - Private

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
    
    enum HTTPMethod: String {
        case GET
        case PUT
        case POST
        case DELETE
    }
}