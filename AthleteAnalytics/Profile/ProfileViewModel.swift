//
//  ProfileViewModel.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/7/21.
//

import Combine
import Foundation
class ProfileViewModel: ObservableObject {
    
    private let stravaAPICaller: StravaAPICallerProtocol

    init() {
        self.stravaAPICaller = StravaAPICaller()
    }
    init(stravaAPICaller: StravaAPICallerProtocol) {
        self.stravaAPICaller = stravaAPICaller
    }
    convenience init(activityStats: ActivityStats) {
        self.init()
        self.activityStats = activityStats
    }
    private var cancellables = Set<AnyCancellable>()
    
    @Published var athlete: Athlete?
    @Published var activityStats: ActivityStats?
    @Published var error: Error?
    
    var profilePictureUrl = URL(string: "")
    
    func getActivityDistance(activityType: ActivityType) -> String {
        if let activityStats = activityStats {
            let result = getCorrectTotals(activityType: activityType, activityStats: activityStats).distance
            return "\(String(format: "%.1f", result))m"
        }
        return "0m"
    }
    func getActivityCount(activityType: ActivityType) -> String {
        if let activityStats = activityStats {
            let result = getCorrectTotals(activityType: activityType, activityStats: activityStats).count
            return "\(result)"
        }
        return "0"
    }
    func getActivityDuration(activityType: ActivityType) -> String {
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

    func getAthlete() {
        stravaAPICaller.getAthlete()
            .sink { completion in
                switch completion {
                case .finished:
                    print("GetAthlete Finished")
                case .failure(let err):
                    self.error = err
                }
            }
        receiveValue: { [weak self] athleteData in
            self?.athlete = athleteData
            if let url = URL(string: athleteData.profile!) {
                self?.profilePictureUrl = url
            }
            self?.getActivityStats()
        }
        .store(in: &cancellables)
    }
    
    func getActivityStats() {
        guard let athlete = athlete else {
            print("Athlete not defined")
            return
        }
        stravaAPICaller.getAthleteStats(id: athlete.id)
            .sink { completion in
                switch completion {
                case .finished:
                    print("GetActivityStats Finished")
                case .failure(let err):
                    self.error = err
                }
            }
        receiveValue: { [weak self] activityStats in
            self?.activityStats = activityStats
            print(activityStats)
        }
        .store(in: &cancellables)
    }
    //MARK: - Private Functions
    
    private func getCorrectTotals(activityType: ActivityType, activityStats: ActivityStats) -> ActivityStats.ActivityTotal{
        switch activityType {
        case .run:
            return activityStats.allRunTotals
        case .swim:
            return activityStats.allRideTotals
        case .ride:
            return activityStats.allSwimTotals
        }
    }
    
}
enum ActivityType {
    case run
    case swim
    case ride
}
//// Added for working preview
//extension ProfileViewModel{
//   convenience init(forPreview: Bool = true) {
//      // Hard coded your mock data for preview
//       self.init()
//       self.athlete = Athlete(id: 15681412, username: nil, resourceState: 2, firstname: "MockFirst", lastname: "MockLast", bio: "", city: "", state: "", country: nil, sex: "M", premium: false, summit: false, createdAt: "", updatedAt: "", badgeTypeID: 0, weight: 80.0, profileMedium: "https://dgalywyr863hv.cloudfront.net/pictures/athletes/15681412/22349770/1/medium.jpg", profile: "https://dgalywyr863hv.cloudfront.net/pictures/athletes/15681412/22349770/1/large.jpg", friend: nil, follower: nil)
//   }
//}
