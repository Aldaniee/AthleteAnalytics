//
//  SignInViewModel.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import Foundation
import Combine
import AuthenticationServices

class SignInViewModel: NSObject, ObservableObject {

    private var cancellables = Set<AnyCancellable>()
    
    func signIn(signedIn: @escaping (Bool) -> Void) {
        StravaAuthManager.shared.authenticate(context: self)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("Error is \(err.localizedDescription)")
                case .finished:
                    print("exchangeCodeForToken Finished")
                }
                
            }
            receiveValue: { result in
                signedIn(result)

            }
            .store(in: &cancellables)
        
    }

}

extension SignInViewModel: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
