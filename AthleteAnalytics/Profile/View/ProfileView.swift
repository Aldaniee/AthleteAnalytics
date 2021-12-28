//
//  ContentView.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/7/21.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var viewModel: ProfileViewModel
    var body: some View {
        Group {
            if viewModel.userData.dataFetcher.isSignedIn {
                profileView
            }
            else {
                signInView
            }
        }
    }
    
    var profileView: some View {
        NavigationView {
            VStack {
                profilePic
                name
                signOut
                Text("All Time Stats")
                    .font(.title)
                totalDisplay
                    .font(.headline)
                    .padding()
                Spacer()
            }
        }.onAppear {
            viewModel.fetchAthlete()
        }
    }
    
    var signInView: some View {
        Button("Sign In") {
            viewModel.signIn()
        }
    }
    @ViewBuilder
    var totalDisplay: some View {
        TabView {
            ForEach(ActivityType.allCases, id: \.self) { type in
                VStack {
                    Text("\(viewModel.userData.getActivityCount(type)) \(type.name)s")
                    Text(viewModel.userData.getActivityDistance(type))
                    Text(viewModel.userData.getActivityDuration(type))
                }
                .tabItem {
                    type.image
                }
            }
        }
    }
    var profilePic: some View {
        AsyncImage(url: viewModel.userData.profilePictureUrl)
            .frame(width: 124, height: 124, alignment: .center)
            .clipShape(Circle())
    }
    
    var name: some View {
        HStack {
            Group {
                Text(viewModel.userData.athlete?.firstname ?? "first")
                Text(viewModel.userData.athlete?.lastname ?? "last")
            }
        }
    }
    
    var signOut: some View {
        Button("Sign Out") {
            viewModel.signOut()
        }
    }
    
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(viewModel: ProfileViewModel())
    }
}
