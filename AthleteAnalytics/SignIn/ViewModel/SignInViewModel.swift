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
    
    func signIn(signedIn: @escaping (Bool) -> Void) {
        StravaAuthManager.shared.authenticate()
        let url: String = "https://www.strava.com/oauth/mobile/authorize?client_id=\(Keys.clientId)&redirect_uri=\(Constants.urlScheme)\(Keys.fallbackUrl)&response_type=code&approval_prompt=auto&scope=read"
        guard let authenticationUrl = URL(string: url) else { return }

        StravaAuthManager.shared.authSession = ASWebAuthenticationSession(url: authenticationUrl, callbackURLScheme: "\(Constants.urlScheme)") { url, error in
            if let error = error {
                print(error)
                signedIn(false)
            } else {
                if let url = url {
                    print(url)
                    signedIn(true)
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
