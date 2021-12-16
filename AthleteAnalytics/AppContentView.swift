//
//  AppContentView.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import Foundation
import SwiftUI

struct AppContentView: View {
    @State var signedInState = StravaAuthManager.shared.isSignedIn

    var body: some View {
        return Group {
            if signedInState {
                ProfileView(signedInState: $signedInState)
            }
            else {
                SignInView(signedInState: $signedInState)
            }
        }
    }
}
