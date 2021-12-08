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

//    init() {
//        athlete = Athlete(id: 15681412, username: nil, resourceState: 2, firstname: "MockFirst", lastname: "MockLast", bio: "", city: "", state: "", country: nil, sex: "M", premium: false, summit: false, createdAt: "", updatedAt: "", badgeTypeID: 0, weight: 80.0, profileMedium: "https://dgalywyr863hv.cloudfront.net/pictures/athletes/15681412/22349770/1/medium.jpg", profile: "https://dgalywyr863hv.cloudfront.net/pictures/athletes/15681412/22349770/1/large.jpg", friend: nil, follower: nil)
//        viewModel = ProfileViewModel()
//    }
    

    @ObservedObject var viewModel = ProfileViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    VStack {
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio( contentMode: .fit)
                            .frame(width: 124, height: 124, alignment: .center)
                        HStack {
                            Spacer()
                            Group {
                                Text(viewModel.athlete?.firstname ?? "first")
                                Text(viewModel.athlete?.lastname ?? "last")
                            }
                            Spacer()

                        }
                        Button("Sign Out", action: {
                            signedInState = false
                        })
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                }
            }
        }.onAppear {
            viewModel.getAthleteData()
        }
    }
}
//struct ProfileView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        ProfileView()
//    }
//}