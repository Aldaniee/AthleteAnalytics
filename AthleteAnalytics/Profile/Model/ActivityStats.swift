//
//  Stats.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/20/21.
//

import Foundation

struct ActivityStats: Codable, Hashable {
    
    let biggestRideDistance,
        biggestClimbElevationGain: Double
    
    var recentRideTotals,
        recentRunTotals,
        recentSwimTotals,
        
        ytdSwimTotals,
        ytdRideTotals,
        ytdRunTotals,
        
        allSwimTotals,
        allRunTotals,
        allRideTotals: ActivityTotal

    enum CodingKeys: String, CodingKey {
        
        case biggestClimbElevationGain = "biggest_climb_elevation_gain"
        case biggestRideDistance = "biggest_ride_distance"

        case recentRunTotals = "recent_run_totals"
        case recentSwimTotals = "recent_swim_totals"
        case recentRideTotals = "recent_ride_totals"

        case ytdRideTotals = "ytd_ride_totals"
        case ytdRunTotals = "ytd_run_totals"
        case ytdSwimTotals = "ytd_swim_totals"
        
        case allSwimTotals = "all_swim_totals"
        case allRideTotals = "all_ride_totals"
        case allRunTotals = "all_run_totals"
        

    }
    struct ActivityTotal: Codable, Hashable {
        static let empty: ActivityTotal = ActivityTotal(achievementCount: nil, count: 0, elapsedTime: 0, elivationGain: 0.0, distance: 0.0, movingTime: 0)
        
        let achievementCount: Int?
        let count, elapsedTime: Int
        let elivationGain, distance: Double
        let movingTime: Int
        
        enum CodingKeys: String, CodingKey {
            case distance
            case achievementCount = "achievement_count"
            case count
            case elapsedTime = "elapsed_time"
            case elivationGain = "elevation_gain"
            case movingTime = "moving_time"
        }
    }
    enum ActivityType {
        case run
        case swim
        case ride
    }
}
