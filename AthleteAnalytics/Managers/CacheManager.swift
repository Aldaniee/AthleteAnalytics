//
//  CacheManager.swift
//  AthleteAnalytics
//
//  Created by Aidan Lee on 12/17/21.
//

import Foundation
import SwiftUI

class CacheManager {
    static let shared = CacheManager()
    
    private var profile: NSCache = NSCache<NSString, UIImage>()
    
    subscript(key: String) -> UIImage? {
        get { profile.object(forKey: key as NSString) }
        set(image) { image == nil ? self.profile.removeObject(forKey: (key as NSString)) : self.profile.setObject(image!, forKey: (key as NSString)) }
    }
}
