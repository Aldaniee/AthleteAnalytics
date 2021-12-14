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
    static let authenticatedAthlete = "/athlete"
    static let athleteStats = "/stats"
    static let urlScheme = "athleteanalytics://".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    static let fallbackUrl = "athleteanalytics.com"
}
