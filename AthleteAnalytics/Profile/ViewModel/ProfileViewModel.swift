//
//  ProfileViewModel.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/7/21.
//

import Combine
import SwiftUI

class ProfileViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    @Published var athlete: Athlete?
    
    func getAthleteData() {
        StravaAPICaller.shared.getAthlete()
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("Error is \(err.localizedDescription)")
                case .finished:
                    print("Finished")
                }
            }
        receiveValue: { [weak self] athleteData in
            self?.athlete = athleteData
        }
        .store(in: &cancellables)

    }

}

