//
//  Athlete.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/6/21.
//

import Foundation

struct Athlete: Codable, Identifiable, Hashable{
    let id: Int
    let username: String?
    let resourceState: Int
    let firstname, lastname, bio, city: String?
    let state: String?
    let country: String?
    let sex: String?
    let premium, summit: Bool
    let createdAt, updatedAt: String?
    let badgeTypeID: Int
    let weight: Double
    let profileMedium, profile: String?
    let friend, follower: String?

    enum CodingKeys: String, CodingKey {
        case id, username
        case resourceState = "resource_state"
        case firstname, lastname, bio, city, state, country, sex, premium, summit
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case badgeTypeID = "badge_type_id"
        case weight
        case profileMedium = "profile_medium"
        case profile, friend, follower
    }
}
