//
//  SignInViewModel.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import Foundation
import SwiftUI
import Combine
import AuthenticationServices

class SignInViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {

    private var cancellables = Set<AnyCancellable>()

    func signIn(signedIn: @escaping (Bool) -> Void) {
        guard let authenticationUrl = URL(string: Constants.webOAuthUrl) else {
            print("url error")
            return
        }

        StravaAuthManager.shared.authSession = ASWebAuthenticationSession(url: authenticationUrl, callbackURLScheme: "\(Constants.urlScheme)") { url, error in
            if let error = error {
                print(error)
                signedIn(false)
            } else {
                if let url = url {
                    let component = URLComponents(string: url.absoluteString)
                    guard let code = component?.queryItems?.first(where: {$0.name == "code"})?.value else {
                        print("no code found")
                        return
                    }
                    print("Code: \(code)")
                    StravaAuthManager.shared.exchangeCodeForToken(code: code)
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
                .store(in: &self.cancellables)
                }
            }
        }

        StravaAuthManager.shared.authSession?.presentationContextProvider = self
        StravaAuthManager.shared.authSession?.start()
    }
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
