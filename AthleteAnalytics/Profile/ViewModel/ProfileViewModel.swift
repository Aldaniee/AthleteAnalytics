//
//  ProfileViewModel.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/7/21.
//

import Combine
import Foundation
class ProfileViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    @Published var athlete: Athlete?
    var url = URL(string: "")
    
    func getAthleteData() {
        StravaAPICaller.shared.getAthlete()
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("Error is \(err.localizedDescription)")
                case .finished:
                    print("GetAthlete Finished")
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

