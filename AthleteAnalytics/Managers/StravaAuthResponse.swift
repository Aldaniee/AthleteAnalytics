//
//  StravaAuthResponse.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import Foundation

struct StravaAuthResponse: Codable {
    let tokenType: String
    let expiresAt, expiresIn: Int
    let refreshToken, accessToken: String

    enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case expiresAt = "expires_at"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case accessToken = "access_token"
    }
}
