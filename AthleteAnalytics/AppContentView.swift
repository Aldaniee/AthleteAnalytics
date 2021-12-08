//
//  AppContentView.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import Foundation
import SwiftUI

struct AppContentView: View {
    
    @State var signInSuccess = false
    @ObservedObject var viewModel = SignInViewModel()

    var body: some View {
        return Group {
            if signInSuccess {
                ProfileView(viewModel: ProfileViewModel())
            }
            else {
                SignInView(viewModel: SignInViewModel(), signInSuccess: $signInSuccess)
            }
        }
    }
}
