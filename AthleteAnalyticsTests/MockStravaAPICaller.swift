//
//  MockStravaAPICaller.swift
//  AthleteAnalyticsTests
//
//  Created by Aidan Lee on 12/18/21.
//

import Foundation
import Combine
@testable import AthleteAnalytics

final class MockStravaAPICaller: StravaAPICallerProtocol {
    
    static var mockAthlete = Athlete(id: 15681412, username: nil, resourceState: 2, firstname: "MockFirst", lastname: "MockLast", bio: "", city: "", state: "", country: nil, sex: "M", premium: false, summit: false, createdAt: "", updatedAt: "", badgeTypeID: 0, weight: 80.0, profileMedium: "https://dgalywyr863hv.cloudfront.net/pictures/athletes/15681412/22349770/1/medium.jpg", profile: "https://dgalywyr863hv.cloudfront.net/pictures/athletes/15681412/22349770/1/large.jpg", friend: nil, follower: nil)
    
    var getAthleteResult: Future<Athlete, Error> = Future { promise in
        return promise(.success(MockStravaAPICaller.mockAthlete))
    }
    
    func getAthlete() -> Future<Athlete, Error> {
        return getAthleteResult
    }
}
