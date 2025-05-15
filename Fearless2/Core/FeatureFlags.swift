//
//  FeatureFlags.swift
//  TrueBlob
//
//  Created by Yue Deng-Wu on 2/2/24.
//

import Foundation

struct FeatureFlags {
    static let isStaging = {
        #if DEBUG
        true
        #else
        false
        #endif
    }()
}

//var featureFlags = {
//    #if DEBUG
//    FeatureFlags(isStaging: true)
//    #else
//    FeatureFlags(isStaging: false)
//    #endif
//}()
//
