//
//  StravaAuthManager.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import Foundation
import Combine
import AuthenticationServices

//protocol StravaAuthManagerProtocol {
//    var isSignedIn: Bool { get }
//    var accessToken: String? { get }
//    var refreshToken: String? { get }
//    var tokenExpirationDate: Date? { get }
//    func authenticate(context: ASWebAuthenticationPresentationContextProviding) -> Future<Bool, Error>
//    func withValidToken(completion: @escaping (String) -> Void)
//    func exchangeCodeForToken(code: String) -> Future<Bool, Error>
//    func refreshIfNeeded() -> Future<Bool, Error>
//    func storeTokens(result: StravaAuthResponse)
//    func signOut()
//}

class StravaAuthManager {
    
    static let shared = StravaAuthManager()

    // MARK: - Public Variables
    var isSignedIn: Bool {
        return accessToken != nil
    }
    var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expires_in") as? Date
    }
    
    // MARK: - Private Variables
    private var authSession: ASWebAuthenticationSession?
    private var cancellables = Set<AnyCancellable>()
    private init() {}
    
    private var refreshingToken = false
    private var code = ""
    private var refreshTokenURL: URL? {
        let string = "\(Constants.baseURL)/token?client_id=\(Keys.stravaClientId)&client_secret=\(Keys.stravaClientSecret)&code=\(self.code)&grant_type=authorization_code"
        return URL(string: string)
    }
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }

    // MARK: - Public Functions
    
    public func authenticate(context: ASWebAuthenticationPresentationContextProviding) -> Future<Bool, Error> {
        return Future() { [weak self] promise in
            guard let self = self, let authenticationUrl = URL(string: Constants.webOAuthUrl) else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            self.authSession = ASWebAuthenticationSession(url: authenticationUrl, callbackURLScheme: Constants.urlScheme) { url, error in
                if let error = error {
                    print(error)
                    return promise(.failure(NetworkError.responseError))
                } else {
                    if let url = url {
                        let component = URLComponents(string: url.absoluteString)
                        guard let code = component?.queryItems?.first(where: {$0.name == "code"})?.value else {
                            print("no code found")
                            return promise(.failure(NetworkError.unknown))
                        }
                        self.exchangeCodeForToken(code: code)
                            .sink { completion in
                                switch completion {
                                case .failure(let err):
                                    print("Error is \(err.localizedDescription)")
                                case .finished:
                                    promise(.success(true))
                                }

                            } receiveValue: { _ in }.store(in: &self.cancellables)
                    }
                }
            }
            self.authSession?.presentationContextProvider = context
            self.authSession?.start()
        }
    }
    
    /// Supplies valid token to be used with API Calls
    /// There are three scenarios here:
    /// 1. Stored token is valid
    /// 2. Stored token is invalid and needs refreshing
    /// 3. Stored token is currently being refreshed
    public func withValidToken(completion: @escaping (String) -> Void) {
        if refreshingToken || !shouldRefreshToken {
            if let token = accessToken {
                completion(token)
            }
            return
        }

        // Refresh
        refreshIfNeeded()
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("Error is \(err.localizedDescription)")
                case .finished:
                    print("Finished")
                }
            }
        receiveValue: { result in
            if let token = self.accessToken, result {
                completion(token)
            }
            
        }
        .store(in: &self.cancellables)
    }
    public func exchangeCodeForToken(code: String) -> Future<Bool, Error> {
        return Future { [weak self] promise in
            // Get Token
            guard let self = self, let url = URL(string: Constants.tokenUrl) else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            var components = URLComponents()
            components.queryItems = [
                URLQueryItem(name: "client_id", value: Keys.stravaClientId),
                URLQueryItem(name: "client_secret", value: Keys.stravaClientSecret),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "grant_type", value: "authorization_code")
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = components.query?.data(using: .utf8)
            
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw NetworkError.responseError
                    }
                    return data
                }
                .decode(type: StravaAuthResponse.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
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
                    else {
                        promise(.success(true))
                    }
                }, receiveValue: {
                    self.storeTokens(result: $0)
                })
                .store(in: &self.cancellables)
        }
    }
    /// true if new token needed and refreshed
    /// false if new token not needed and nothing is done
    /// error if new token needed and not refereshed
    public func refreshIfNeeded() -> Future<Bool, Error> {
        return Future { [weak self] promise in
            
            // Refresh the token
            guard let self = self, let url = self.refreshTokenURL else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            guard !self.refreshingToken else {
                return promise(.success(false))
            }

            guard self.shouldRefreshToken else {
                return promise(.success(false))
            }

            guard let refreshToken = self.refreshToken else{
                return promise(.failure(NetworkError.unknown))
            }


            self.refreshingToken = true

            var components = URLComponents()
            components.queryItems = [
                URLQueryItem(name: "grant_type",
                             value: "refresh_token"),
                URLQueryItem(name: "refresh_token",
                             value: refreshToken),
            ]

            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { (data, response) -> Data in
                    guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                        throw NetworkError.responseError
                    }
                    return data
                }
                .decode(type: StravaAuthResponse.self, decoder: JSONDecoder())
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
                    self.storeTokens(result: $0)
                    promise(.success(true))
                    
                })
                .store(in: &self.cancellables)
        }
    }
    public func signOut() {
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "expires_in")
    }
    // MARK: - Internal Functions
    internal func storeTokens(result: StravaAuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        UserDefaults.standard.setValue(result.refresh_token, forKey: "refresh_token")
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expires_in")
    }
}
