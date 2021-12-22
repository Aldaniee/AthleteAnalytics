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
                    runTotalDisplay
                    rideTotalDisplay
                    swimTotalDisplay
                }.font(.headline).padding()
                Spacer()
            }
        }.onAppear {
            viewModel.getAthlete()
        }
    }
    var runTotalDisplay: some View {
        return VStack {
            Text("\(viewModel.getActivityCount(.run)) Runs")
            Text(viewModel.getActivityDistance(.run))
            Text(viewModel.getActivityDuration(.run))
        }
    }
    var rideTotalDisplay: some View {
        return VStack {
            Text("\(viewModel.getActivityCount(.ride)) Rides")
            Text(viewModel.getActivityDistance(.ride))
            Text(viewModel.getActivityDuration(.ride))
        }
    }
    var swimTotalDisplay: some View {
        return VStack {
            Text("\(viewModel.getActivityCount(.swim)) Swims")
            Text(viewModel.getActivityDistance(.swim))
            Text(viewModel.getActivityDuration(.swim))
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
