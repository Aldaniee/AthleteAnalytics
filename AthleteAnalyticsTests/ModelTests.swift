//
//  ActivityStatsTests.swift
//  AthleteAnalyticsTests
//
//  Created by Aidan Lee on 12/22/21.
//

import XCTest
@testable import AthleteAnalytics

class ModelTests: XCTestCase {
    
    func testDecodeAthleteStatsFromMockJson() {
        var activityStats: ActivityStats?
        if let path = Bundle.main.path(forResource: "MockJSONAthleteStats", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                activityStats = try JSONDecoder().decode(ActivityStats.self, from: data)
            }
            catch {
                print(error)
            }
            XCTAssertNotNil(activityStats)
        }
        else {
            XCTFail("Error in MockJSON Path")
        }
    }
    func testDecodeSummaryActivityFromMockJson() {
        var summaryActivity: SummaryActivity?
        if let path = Bundle.main.path(forResource: "MockJSONSummaryActivity", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                summaryActivity = try JSONDecoder().decode(SummaryActivity.self, from: data)
            }
            catch {
                print(error)
            }
            XCTAssertNotNil(summaryActivity)
        }
        else {
            XCTFail("Error in MockJSON Path")
        }
    }
    func testDecodeListAthleteActivitiesResponse() {
        var summaryActivity: [SummaryActivity] = []
        if let path = Bundle.main.path(forResource: "MockJSONListAthleteActivitiesReponse", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                summaryActivity = try JSONDecoder().decode([SummaryActivity].self, from: data)
            }
            catch {
                print(error)
            }
            XCTAssertTrue(summaryActivity.count == 2)
        }
        else {
            XCTFail("Error in MockJSON Path")
        }
    }
}
