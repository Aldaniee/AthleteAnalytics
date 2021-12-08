//
//  Response.swift
//  StravaAthleteAnalytics
//
//  Created by Aidan Lee on 12/6/21.
//

import Foundation

struct Response : Decodable {
    var items: Athlete
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode(Athlete.self, forKey: .items)
    }
}
