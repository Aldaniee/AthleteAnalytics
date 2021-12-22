//
//  ActivityStatsTests.swift
//  AthleteAnalyticsTests
//
//  Created by Aidan Lee on 12/22/21.
//

import XCTest
@testable import AthleteAnalytics

class ActivityStatsTests: XCTestCase {

    override func setUp() {

    }
    func testGetAthleteWithCorrectAuthenticationSetsAthleteData() {
        var activityStats: ActivityStats?
        if let path = Bundle.main.path(forResource: "MockJSONAthleteStats", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                activityStats = try JSONDecoder().decode(ActivityStats.self, from: data)
            }
            catch {
                XCTAssertTrue(false)
            }
        }
        XCTAssertNotNil(activityStats)
    }
}
