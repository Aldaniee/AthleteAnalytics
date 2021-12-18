//
//  ProfileViewModelSpec.swift
//  AthleteAnalyticsTests
//
//  Created by Aidan Lee on 12/18/21.
//

import XCTest
import Combine
@testable import AthleteAnalytics

class ProfileViewModelSpec: XCTestCase {

    var viewModel: ProfileViewModel!
    var mockStravaAPICaller: MockStravaAPICaller!
    
    override func setUp() {
        mockStravaAPICaller = MockStravaAPICaller()
        viewModel = .init(stravaAPICaller: mockStravaAPICaller)
    }
    
    func testGetAthleteWithCorrectAuthenticationSetsAthleteData() {
        mockStravaAPICaller.getAthleteResult = Future { promise in
            return promise(.success(MockStravaAPICaller.mockAthlete))
        }
        
        viewModel.getAthlete()
        XCTAssertTrue(viewModel.athlete?.id == MockStravaAPICaller.mockAthlete.id)
        XCTAssertTrue(viewModel.url == URL(string: MockStravaAPICaller.mockAthlete.profile!))
    }
    
    func testGetAthleteWithAPIError() {
        mockStravaAPICaller.getAthleteResult = Future { promise in
            return promise(.failure(NetworkError.responseError))
        }
        
        viewModel.getAthlete()
        XCTAssertNil(viewModel.athlete)
        XCTAssertNotNil(viewModel.error)
    }
}
