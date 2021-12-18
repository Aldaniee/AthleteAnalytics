//
//  ContentView.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/7/21.
//

import SwiftUI
import Foundation

struct ProfileView: View {
    @Binding var signedInState: Bool

    @ObservedObject var viewModel = ProfileViewModel()

    var body: some View {
        NavigationView {
            VStack {
                AsyncImage(url: viewModel.url)
                    .frame(width: 124, height: 124, alignment: .center)
                    .clipShape(Circle())
                HStack {
                    Group {
                        Text(viewModel.athlete?.firstname ?? "first")
                        Text(viewModel.athlete?.lastname ?? "last")
                    }
                }
                Button("Sign Out", action: {
                    StravaAuthManager.shared.signOut()
                    signedInState = false
                })
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
        }.onAppear {
            viewModel.getAthlete()
        }
    }
    
}
