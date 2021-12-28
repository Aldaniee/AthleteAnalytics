//
//  UserData.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/28/21.
//

import Foundation
import Combine
import MapKit

struct UserData {
    private var cancellables = Set<AnyCancellable>()

    var isSignedIn = false
    var athlete: Athlete?
    var activityStats: ActivityStats?
    var athleteActivities: [SummaryActivity]?
    var profilePictureUrl: URL?
    
    var dataFetcher = DataFetcher()
    
    mutating func signOut() {
        dataFetcher.signOut()
        self.isSignedIn = false
    }
    
    mutating func signIn(_ result: Bool) {
        self.isSignedIn = result
    }

    // MARK: - Return Stored Data
    func getActivityDistance(_ activityType: ActivityType) -> String {
        if let activityStats = activityStats {
            let result = getCorrectTotals(activityType: activityType, activityStats: activityStats).distance
            let formatter = MKDistanceFormatter()
            formatter.units = .metric
            formatter.unitStyle = .abbreviated
            return formatter.string(fromDistance: result)
        }
        return "0 m"
    }
    func getActivityCount(_ activityType: ActivityType) -> String {
        if let activityStats = activityStats {
            let result = getCorrectTotals(activityType: activityType, activityStats: activityStats).count
            return "\(result)"
        }
        return "0"
    }
    func getActivityDuration(_ activityType: ActivityType) -> String {
        if let activityStats = activityStats {
            let seconds = getCorrectTotals(activityType: activityType, activityStats: activityStats).movingTime
            let duration = TimeInterval(seconds)
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour, .minute]
            formatter.unitsStyle = .abbreviated
            formatter.zeroFormattingBehavior = .dropAll
            return "\(formatter.string(from: duration) ?? "0")"
        }
        return "0"
    }
    //MARK: - Private Functions
    
    private func getCorrectTotals(activityType: ActivityType, activityStats: ActivityStats) -> ActivityStats.ActivityTotal{
        switch activityType {
        case .run:
            return activityStats.allRunTotals
        case .swim:
            return activityStats.allSwimTotals
        case .ride:
            return activityStats.allRideTotals
        }
        
    }
}
