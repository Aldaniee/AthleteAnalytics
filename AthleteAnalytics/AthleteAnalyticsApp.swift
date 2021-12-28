//
//  AthleteAnalyticsApp.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/8/21.
//

import SwiftUI

@main
struct AthleteAnalyticsApp: App {
    private let profile = ProfileViewModel()
    var body: some Scene {
        WindowGroup {
            ProfileView(viewModel: profile)
        }
    }
}
