//
//  SignInViewModel.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import Foundation
import SwiftUI
import AuthenticationServices

class SignInViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    
    func authenticate(authenticated: @escaping (Bool) -> Void) {
        let url: String = "https://www.strava.com/oauth/mobile/authorize?client_id=\(NetworkManager.shared.clientId)&redirect_uri=\(NetworkManager.shared.urlScheme)%3A%2F%2F\(NetworkManager.shared.fallbackUrl)&response_type=code&approval_prompt=auto&scope=read"
        guard let authenticationUrl = URL(string: url) else { return }

        NetworkManager.shared.authSession = ASWebAuthenticationSession(url: authenticationUrl, callbackURLScheme: "\(NetworkManager.shared.urlScheme)") { url, error in
            if let error = error {
                print(error)
                authenticated(false)
            } else {
                if let url = url {
                    print(url)
                    authenticated(true)
                }
            }
        }

        NetworkManager.shared.authSession?.presentationContextProvider = self
        NetworkManager.shared.authSession?.start()
    }
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}
