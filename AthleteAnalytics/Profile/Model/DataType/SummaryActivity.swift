//
//  SummaryActivity.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/27/21.
//

import Foundation

// MARK: - SummaryActivity
struct SummaryActivity: Codable {
    let id: Double
    let externalID: String
    let uploadID: Double
    let athlete: MetaAthlete
    let name: String
    let distance: Double
    let movingTime, elapsedTime: Int
    let totalElevationGain: Double
    let elevHigh, elevLow: Double?
    let resourceState: Int
    let type: String
    let workoutType: Int?
    let startDate, startDateLocal: String
    let timezone: String
    let utcOffset: Int
    let startLatlng, endLatlng, locationCity, locationState: [Double]?
    let locationCountry: String
    let achievementCount, kudosCount, commentCount, athleteCount: Int
    let photoCount: Int
    let map: PolylineMap
    let trainer, commute, manual, welcomePrivate: Bool
    let flagged: Bool
    let gearID: String
    let fromAcceptedTag: Bool
    let averageSpeed, maxSpeed, averageCadence, averageWatts: Double
    let weightedAverageWatts: Int
    let kilojoules: Double
    let deviceWatts, hasHeartrate: Bool
    let averageHeartrate: Double
    let maxHeartrate, maxWatts, prCount, totalPhotoCount: Int
    let hasKudoed: Bool
    let sufferScore: Int

    enum CodingKeys: String, CodingKey {
        case resourceState = "resource_state"
        case athlete, name, distance
        case movingTime = "moving_time"
        case elapsedTime = "elapsed_time"
        case elevHigh = "elev_high"
        case elevLow = "elev_low"
        case totalElevationGain = "total_elevation_gain"
        case type
        case workoutType = "workout_type"
        case id
        case externalID = "external_id"
        case uploadID = "upload_id"
        case startDate = "start_date"
        case startDateLocal = "start_date_local"
        case timezone
        case utcOffset = "utc_offset"
        case startLatlng = "start_latlng"
        case endLatlng = "end_latlng"
        case locationCity = "location_city"
        case locationState = "location_state"
        case locationCountry = "location_country"
        case achievementCount = "achievement_count"
        case kudosCount = "kudos_count"
        case commentCount = "comment_count"
        case athleteCount = "athlete_count"
        case photoCount = "photo_count"
        case map, trainer, commute, manual
        case welcomePrivate = "private"
        case flagged
        case gearID = "gear_id"
        case fromAcceptedTag = "from_accepted_tag"
        case averageSpeed = "average_speed"
        case maxSpeed = "max_speed"
        case averageCadence = "average_cadence"
        case averageWatts = "average_watts"
        case weightedAverageWatts = "weighted_average_watts"
        case kilojoules
        case deviceWatts = "device_watts"
        case hasHeartrate = "has_heartrate"
        case averageHeartrate = "average_heartrate"
        case maxHeartrate = "max_heartrate"
        case maxWatts = "max_watts"
        case prCount = "pr_count"
        case totalPhotoCount = "total_photo_count"
        case hasKudoed = "has_kudoed"
        case sufferScore = "suffer_score"
    }
}

// MARK: - MetaAthlete
struct MetaAthlete: Codable {
    let id, resourceState: Int

    enum CodingKeys: String, CodingKey {
        case id
        case resourceState = "resource_state"
    }
}

// MARK: - Map
struct PolylineMap: Codable {
    let id: String
    let summaryPolyline: String?
    let resourceState: Int

    enum CodingKeys: String, CodingKey {
        case id
        case summaryPolyline = "summary_polyline"
        case resourceState = "resource_state"
    }
}
