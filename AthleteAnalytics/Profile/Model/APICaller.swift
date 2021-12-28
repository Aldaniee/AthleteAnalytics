//
//  NetworkManager.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/6/21.
//

import Foundation
import Combine
import AuthenticationServices

class APICaller {
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Functions
    func makeCall<T: Decodable>(to endpoint: Endpoint, token: String? = nil) -> Future<T, Error> {
        return Future { [weak self] promise in
            // Build URL
            guard let self = self, let url = endpoint.url else {
                return promise(.failure(NetworkError.invalidURL))
            }
            // Make Request
            self.createRequest(with: url, endpoint: endpoint, token: token) { request in
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
    
    func createRequest(
        with url: URL?,
        endpoint: Endpoint,
        token: String?,
        completion: @escaping (URLRequest) -> Void
    ) {
        guard let apiURL = url else {
            print("URL Error")
            return
        }
        var request = URLRequest(url: apiURL)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = 30
        if endpoint.method == .POST {
            let components = endpoint.urlComponenets
            request.httpBody = components.query?.data(using: .utf8)
        }
        if !endpoint.isAuthRequest {
            if token == nil {
                print("Token Error")
            }
            else {
                request.setValue("Bearer \(token!)", forHTTPHeaderField: "Authorization")
            }
        }
        completion(request)
    }
}
