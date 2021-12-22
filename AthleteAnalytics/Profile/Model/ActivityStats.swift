//
//  Stats.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/20/21.
//

import Foundation

struct ActivityStats: Hashable {
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
        
    //
    //    static let zeroTotal = ActivityTotal(achievementCount: 0, count: 0, elapsedTime: 0, elevationGain: 0.0, distance: 0.0, movingTime: 0)
        
        let achievementCount, count, elapsedTime: Int
        let elevationGain, distance: Double
        let movingTime: Int

        enum CodingKeys: String, CodingKey {
            case distance
            case achievementCount = "achievement_count"
            case count
            case elapsedTime = "elapsed_time"
            case elevationGain = "elevation_gain"
            case movingTime = "moving_time"
        }
    }
}
extension ActivityStats: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        do { biggestRideDistance = try values.decode(Double.self, forKey: .biggestRideDistance) }
        do { biggestClimbElevationGain = try values.decode(Double.self, forKey: .biggestClimbElevationGain) }
        
        do { recentRideTotals = try values.decode(ActivityTotal.self, forKey: .recentRideTotals) }
        do { recentSwimTotals = try values.decode(ActivityTotal.self, forKey: .recentSwimTotals) }
        do { recentRunTotals = try values.decode(ActivityTotal.self, forKey: .recentRunTotals) }
        
        do { ytdRideTotals = try values.decode(ActivityTotal.self, forKey: .ytdRideTotals) }
        do { ytdSwimTotals = try values.decode(ActivityTotal.self, forKey: .ytdSwimTotals) }
        do { ytdRunTotals = try values.decode(ActivityTotal.self, forKey: .ytdRunTotals) }
        
        do { allRideTotals = try values.decode(ActivityTotal.self, forKey: .allRideTotals) }
        do { allSwimTotals = try values.decode(ActivityTotal.self, forKey: .allSwimTotals) }
        do { allRunTotals = try values.decode(ActivityTotal.self, forKey: .allRunTotals) }
    }
}
extension ActivityStats: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.biggestRideDistance, forKey: .biggestRideDistance)
        try container.encode(self.biggestClimbElevationGain, forKey: .biggestClimbElevationGain)

        try container.encode(self.recentRunTotals, forKey: .recentRunTotals)
        try container.encode(self.recentSwimTotals, forKey: .recentSwimTotals)
        try container.encode(self.recentRideTotals, forKey: .recentSwimTotals)

        try container.encode(self.ytdRunTotals, forKey: .ytdRunTotals)
        try container.encode(self.ytdRideTotals, forKey: .ytdRideTotals)
        try container.encode(self.ytdSwimTotals, forKey: .ytdSwimTotals)
        
        try container.encode(self.allRunTotals, forKey: .allRunTotals)
        try container.encode(self.allSwimTotals, forKey: .allSwimTotals)
        try container.encode(self.allRideTotals, forKey: .allRideTotals)

    }
}
