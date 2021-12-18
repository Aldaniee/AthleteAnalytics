//
//  Constants.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import Foundation

public struct Constants {
    
    // Strava endpoints
    static let baseURL = "https://www.strava.com/api/v3"
    static let tokenUrl = "https://www.strava.com/oauth/token"
    
    static let urlScheme = "athleteanalytics://".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    static let fallbackUrl = "athleteanalytics.com"
    
    static var webOAuthUrl : String {
        let string = "https://www.strava.com/oauth/mobile/authorize?client_id=\(Keys.stravaClientId)&redirect_uri=\(Constants.urlScheme)\(Constants.fallbackUrl)%2Fen-US&response_type=code&approval_prompt=auto&scope=activity%3Awrite%2Cread&state=test"
        return string
    }
}
