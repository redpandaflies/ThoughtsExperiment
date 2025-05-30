//
//  MixpanelService.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/11/25.
//
import Foundation
import Mixpanel
import OSLog

class MixpanelService {
    
    static let shared = MixpanelService()
    
    private init() {}
    
    let loggerMixpanel = Logger.mixpanelEvents
    let loggerCoreData = Logger.coreDataEvents
    
    func setUserProfile(distinctId: String, name: String) {
        Mixpanel.mainInstance().identify(distinctId: distinctId)
        
        if !name.isEmpty {
            Mixpanel.mainInstance().people.set(properties: [
                "$name": name,
                "$user_id": distinctId
            ])
        } else {
            Mixpanel.mainInstance().people.set(properties: [
                "$user_id": distinctId
            ])
        }
   }
}
