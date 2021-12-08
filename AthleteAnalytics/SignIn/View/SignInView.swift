//
//  SignInView.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import SwiftUI
import Foundation

struct SignInView: View {
    @Binding var signedInState: Bool

    @ObservedObject var viewModel = SignInViewModel()
    var body: some View {
        Button("Sign In", action: {
            viewModel.authenticate { result in
                signedInState = result
            }
        })
    }
    
}

//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInView()
//    }
//}

