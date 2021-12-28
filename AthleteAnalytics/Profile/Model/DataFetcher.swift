//
//  StravaDataManager.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import Foundation
import Combine
import AuthenticationServices
import SwiftUI

protocol DataFetcherProtocol {
    func getAthlete() -> Future<Athlete, Error>
    func getAthleteStats(id: Int) -> Future<ActivityStats, Error>
    func getAthleteActivities(since date: Date?) -> Future<[SummaryActivity], Error>
}

class DataFetcher: DataFetcherProtocol {
    
    // MARK: - Public Variables
    var isSignedIn: Bool {
        return accessToken != nil
    }
    var accessToken: String? {
        if !self.refreshingToken && self.shouldRefreshToken {
            self.refreshIfNeeded()
        }
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expires_in") as? Date
    }

    // MARK: - Private Variables
    let stravaAPICaller: APICaller
        
    private var authSession: ASWebAuthenticationSession?
    private var cancellables = Set<AnyCancellable>()
    
    private var refreshingToken = false
    private var code = ""
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }

    // MARK: - Public Functions
    init() { self.stravaAPICaller = APICaller() }
    init(activityStats: ActivityStats) {
        self.stravaAPICaller = APICaller()
    }
    
    // MARK: - Public Functions
    
    func getAthleteStats(id: Int) -> Future<ActivityStats, Error> {
        stravaAPICaller.makeCall(to: .stats(athleteId: id), token: accessToken)
    }
    func getAthleteActivities(since date: Date?) -> Future<[SummaryActivity], Error> {
        return stravaAPICaller.makeCall(to: .athleteActivities(before: Date().timeIntervalSince1970, after: nil, page: 1, perPage: 30), token: accessToken)
    }
    func getAthlete() -> Future<Athlete, Error> {
        return stravaAPICaller.makeCall(to: .athlete, token: accessToken)
    }
    
    // MARK: - Authentication Functions
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
                        self.code = code
                        self.exchangeCodeForToken(code: code)
                            .sink { completion in
                                switch completion {
                                case .failure(let err):
                                    print("Error is \(err.localizedDescription)")
                                case .finished:
                                    promise(.success(true))
                                }

                            } receiveValue: {
                                self.storeTokens(result: $0)
                            }.store(in: &self.cancellables)
                    }
                }
            }
            self.authSession?.presentationContextProvider = context
            self.authSession?.start()
        }
    }
    
    public func exchangeCodeForToken(code: String) -> Future<StravaAuthResponse, Error> {
        return stravaAPICaller.makeCall(to: .exchange(code: code))
    }
    /// true if new token needed and refreshed
    /// false if new token not needed and nothing is done
    /// error if new token needed and not refereshed
    public func refreshIfNeeded() {
        if shouldRefreshToken && !refreshingToken {
            refreshingToken = true
            _ = stravaAPICaller.makeCall(to: .refresh(code: code, refreshToken: refreshToken))
            .sink(receiveCompletion: { _ in }) {
                self.storeTokens(result: $0)
            }
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
        refreshingToken = false
    }
}
