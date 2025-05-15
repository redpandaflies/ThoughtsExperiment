//
//  ImageCacheManager.swift
//  TrueBlob
//
//  Created by Yue Deng-Wu on 3/17/24.
//

import Foundation
import SwiftUI

class ImageCacheManager {
    
    static let instance = ImageCacheManager()
    
    private init() {}
    
    var photoCache: NSCache<NSString, UIImage> = {
       var cache = NSCache<NSString, UIImage>()
        cache.countLimit = 15
        cache.totalCostLimit = 1024 * 1024 * 150 //150mb
        return cache
    }()
    
    func saveImage(key: String, value: UIImage) {
        photoCache.setObject(value, forKey: key as NSString)
    }
    
    func getImage(key: String) -> UIImage? {
        return photoCache.object(forKey: key as NSString)
    }
    
    func deleteImage(key: String) {
        photoCache.removeObject(forKey: key as NSString)
    }
}
