//
//  Endpoint.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/27/21.
//

import Foundation

enum Endpoint {
    // POST endpoints
    // Authentication
    case refresh(code: String, refreshToken: String?)
    case exchange(code: String)
    
    // GET endpoints
    case athlete
    case athleteActivities(before: Double, after: Double?, page: Int, perPage: Int)
    case stats(athleteId: Int)
    var url: URL? {
        switch self {
        case .athlete:
            return URL(string: "\(Constants.baseURL)/athlete")
        case .athleteActivities:
            return URL(string: "\(Constants.baseURL)/athlete/activities")
        case .stats(let athleteId):
            return URL(string: "\(Constants.baseURL)/athletes/\(athleteId)/stats")
        case .refresh(let code, _):
            return URL(string: "\(Constants.baseURL)/token?client_id=\(Keys.stravaClientId)&client_secret=\(Keys.stravaClientSecret)&code=\(code)&grant_type=authorization_code")
        case .exchange:
            return URL(string: Constants.tokenUrl)
        }
    }
    var urlComponenets: URLComponents {
        switch self {
        case .refresh(_, let refreshToken):
            var components = URLComponents()
            components.queryItems = [
                URLQueryItem(name: "grant_type",
                             value: "refresh_token"),
                URLQueryItem(name: "refresh_token",
                             value: refreshToken),
            ]
            return components
        case .exchange(let code):
            var components = URLComponents()
            components.queryItems = [
                URLQueryItem(name: "client_id", value: Keys.stravaClientId),
                URLQueryItem(name: "client_secret", value: Keys.stravaClientSecret),
                URLQueryItem(name: "code", value: code),
                URLQueryItem(name: "grant_type", value: "authorization_code")
            ]
            return components
        default:
            return URLComponents()
        }
    }
    var method: HTTPMethod {
        switch self {
        case .refresh(_, _), .exchange(_):
            return HTTPMethod.POST
        case .athlete, .athleteActivities(_,_,_,_), .stats(_):
            return HTTPMethod.GET
        }
    }
    var isAuthRequest: Bool {
        switch self {
        case .refresh(_, _), .exchange(code: _):
            return true
        default:
            return false
        }
    }
}

enum HTTPMethod: String {
    case GET
    case PUT
    case POST
    case DELETE
}
