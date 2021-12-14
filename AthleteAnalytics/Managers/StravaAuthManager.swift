//
//  StravaAuthManager.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import Foundation
import AuthenticationServices

class StravaAuthManager {
    
    static let shared = StravaAuthManager()
    
    var athlete: Athlete?
    var authSession: ASWebAuthenticationSession?

    private var refreshingToken = false
    
    private var code = ""
    
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
    
    public var appAuthorizeURL : URL {
        let string = "strava://oauth/mobile/authorize?client_id=\(Keys.clientId)&redirect_uri=\(Constants.urlScheme)\(Constants.fallbackUrl)%2Fen-US&response_type=code&approval_prompt=auto&scope=activity%3Awrite%2Cread&state=test"
        return URL(string: string)!
    }
    public var webAuthorizeURL : URL {
        let string = "https://www.strava.com/oauth/mobile/authorize?client_id=\(Keys.clientId)&redirect_uri=\(Constants.urlScheme)\(Constants.fallbackUrl)%2Fen-US&response_type=code&approval_prompt=auto&scope=activity%3Awrite%2Cread&state=test"
        return URL(string: string)!
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    private var onRefreshBlocks = [((String) -> Void)]()

    /// Supplies valid token to be used with API Calls
    public func withValidToken(completion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            // Append the compleiton
            onRefreshBlocks.append(completion)
            return
        }

        if shouldRefreshToken {
            // Refresh
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        }
        else if let token = accessToken {
            completion(token)
        }
    }

    public func refreshIfNeeded(completion: ((Bool) -> Void)?) {
        guard !refreshingToken else {
            return
        }

        guard shouldRefreshToken else {
            completion?(true)
            return
        }

        guard let refreshToken = self.refreshToken else{
            return
        }

        // Refresh the token
        guard let url = URL(string: "\(Constants.baseURL)/token?client_id=\(Keys.clientId)&client_secret=\(Keys.clientSecret)&code=\(code)&grant_type=authorization_code") else {
            return
        }

        refreshingToken = true

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type",
                         value: "refresh_token"),
            URLQueryItem(name: "refresh_token",
                         value: refreshToken),
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.refreshingToken = false
            guard let data = data,
                  error == nil else {
                completion?(false)
                return
            }

            do {
                let result = try JSONDecoder().decode(StravaAuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach { $0(result.accessToken) }
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                completion?(true)
            }
            catch {
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()
    }

    func authenticate() {

        if UIApplication.shared.canOpenURL(appAuthorizeURL) {
            UIApplication.shared.open(appAuthorizeURL, options: [:])
        } else {
            authSession = ASWebAuthenticationSession(url: webAuthorizeURL, callbackURLScheme: "\(Constants.urlScheme)") { url, error in
                if(url?.absoluteString.contains("code") ?? false && url!.absoluteString.contains("scope")) {
                    print("success")
                }
            }

            authSession?.start()
        }
    }
    private func storeTokens(result: StravaAuthResponse) {
        UserDefaults.standard.setValue(result.accessToken, forKey: "access_token")
        UserDefaults.standard.setValue(result.refreshToken, forKey: "refresh_token")
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expiresIn)), forKey: "expires_in")
    }
    private func cacheToken(result: StravaAuthResponse) {
        UserDefaults.standard.setValue(result.accessToken,
                                       forKey: "access_token")
        if result.refreshToken != nil {
            UserDefaults.standard.setValue(Constants.urlScheme,
                                           forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expiresIn)),
                                       forKey: "expires_in")
    }

    public func signOut(completion: (Bool) -> Void) {
        UserDefaults.standard.setValue(nil,
                                       forKey: "access_token")
        UserDefaults.standard.setValue(nil,
                                       forKey: "refresh_token")
        UserDefaults.standard.setValue(nil,
                                       forKey: "expires_in")

        completion(true)
    }
}
