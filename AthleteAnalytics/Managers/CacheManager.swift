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
    
    private var profileImage: NSCache = NSCache<NSString, UIImage>()
    
    subscript(key: String) -> UIImage? {
        get { profileImage.object(forKey: key as NSString) }
        set(image) {
            image == nil
            ? self.profileImage.removeObject(forKey: (key as NSString))
            : self.profileImage.setObject(image!, forKey: (key as NSString))
        }
    }
}
