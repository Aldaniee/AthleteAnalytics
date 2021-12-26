//
//  ContentView.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/7/21.
//

import SwiftUI

struct ProfileView: View {
    

    @Binding var signedInState: Bool
    @ObservedObject var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                profilePic
                name
                signOut
                Spacer()
                Text("All Time Stats").font(.title)
                HStack {
                    TabView {
                        totalDisplay(for: .run)
                        totalDisplay(for: .ride)
                        totalDisplay(for: .swim)
                    }
                }.font(.headline).padding()
            }
        }.onAppear {
            viewModel.getAthlete()
        }
    }
    @ViewBuilder
    func totalDisplay(for type: ActivityType) -> some View {
        VStack {
            Text("\(viewModel.getActivityCount(type)) \(type.name)s")
            Text(viewModel.getActivityDistance(type))
            Text(viewModel.getActivityDuration(type))
        }
        .tabItem {
            type.image
        }
    }
    var profilePic: some View {
        AsyncImage(url: viewModel.profilePictureUrl)
            .frame(width: 124, height: 124, alignment: .center)
            .clipShape(Circle())
    }
    
    var name: some View {
        HStack {
            Group {
                Text(viewModel.firstName)
                Text(viewModel.lastName)
            }
        }
    }
    var signOut: some View {
        Button("Sign Out", action: {
            StravaAuthManager.shared.signOut()
            signedInState = false
        })
    }
    
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(signedInState: .constant(true), viewModel: ProfileViewModel())
    }
}
