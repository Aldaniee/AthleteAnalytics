//
//  StravaAuthResponse.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import Foundation

struct StravaAuthResponse: Codable {
    let token_type: String
    let expires_at, expires_in: Int
    let refresh_token, access_token: String
    let athlete: Athlete

}
