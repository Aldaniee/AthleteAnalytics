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

    init(stravaAPICaller: StravaAPICallerProtocol = StravaAPICaller()) {
        self.stravaAPICaller = stravaAPICaller
    }
    private var cancellables = Set<AnyCancellable>()
    
    @Published var athlete: Athlete?
    @Published var error: Error?
    
    var url = URL(string: "")
    
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
                self?.url = url
            }

        }
        .store(in: &cancellables)

    }

}

