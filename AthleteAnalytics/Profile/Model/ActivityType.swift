//
//  ActivityType.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/26/21.
//

import Foundation
import SwiftUI

enum ActivityType {
    case run
    case swim
    case ride
    var name: String {
        switch self {
        case .run:
            return "Run"
        case .swim:
            return "Swim"
        case .ride:
            return "Ride"
        }
    }
    var image: Image {
        switch self {
        case .run:
            return Image("run")
        case .swim:
            return Image("swim")
        case .ride:
            return Image("bike")
        }
    }
}
