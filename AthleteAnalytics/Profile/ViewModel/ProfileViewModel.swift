//
//  ProfileViewModel.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/7/21.
//

import Combine
import Foundation
import AuthenticationServices

class ProfileViewModel: NSObject, ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
        
    @Published var userData = UserData()
    
    
    //MARK: - Intent(s)
    
    func signIn() {
        userData.dataFetcher.authenticate(context: self).sink { completion in
            switch completion {
            case .failure(let err):
                print("Error is \(err.localizedDescription)")
            case .finished:
                break
            }

        } receiveValue: { result in
            self.userData.signIn(result)
        }.store(in: &self.cancellables)
    }
    func signOut() {
        userData.signOut()
    }
    
    // MARK: - Fetch Data from Strava

    func fetchAthlete() {
        userData.dataFetcher.getAthlete()
            .sink { completion in
                switch completion {
                case .finished:
                    print("GetAthlete Finished")
                case .failure(let err):
                    print("Error: \(err) GetAthlete failed so signing out")
                    self.userData.signOut()
                }
            }
        receiveValue: { [weak self] athleteData in
            self?.userData.athlete = athleteData
            if let url = URL(string: athleteData.profile!) {
                self?.userData.profilePictureUrl = url
            }
            print(athleteData)
            self?.fetchActivityStats()
            self?.fetchAthleteActivities()
        }
        .store(in: &self.cancellables)
    }
    func fetchAthleteActivities() {
        userData.dataFetcher.getAthleteActivities(since: DateConstants.yearAgo)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let err):
                    print("Error: \(err) GetAthleteActivities failed")
                }
            }
        receiveValue: { activites in
            self.userData.athleteActivities = activites
        }
        .store(in: &self.cancellables)
    }

     func fetchActivityStats() {
         guard let athlete = userData.athlete else {
            print("Athlete not defined")
            return
        }
        userData.dataFetcher.getAthleteStats(id: athlete.id)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let err):
                    print("Error: \(err) GetAthleteStats failed")
                }
            }
        receiveValue: { activityStats in
            self.userData.activityStats = activityStats
        }
        .store(in: &self.cancellables)
    }
    private struct DateConstants {
        static let yearAgo = Calendar.current.date(
            byAdding: .year,
            value: -1,
            to: Date())!
    }
}

extension ProfileViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
