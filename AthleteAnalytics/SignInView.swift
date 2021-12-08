//
//  SignInView.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import SwiftUI
import Foundation

struct SignInView: View {
    
    @ObservedObject var viewModel: SignInViewModel
    @Binding var signInSuccess: Bool
    var body: some View {
        Button("Sign In", action: viewModel.authenticate)
    }
    
}

//struct SignInView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignInView()
//    }
//}

