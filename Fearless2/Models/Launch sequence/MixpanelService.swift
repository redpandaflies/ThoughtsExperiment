//
//  MixpanelService.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/11/25.
//
import Foundation
import Mixpanel
import OSLog
import UIKit

final class MixpanelService: ObservableObject {
    
    private var dataController: DataController
    
    let loggerMixpanel = Logger.mixpanelEvents
    let loggerCoreData = Logger.coreDataEvents
        
    init(dataController: DataController) {
        self.dataController = dataController
    }
    
   func setupMixpanelTracking() async {
        
        // Fetch user profile from CoreData asynchronously
       let profileData = await dataController.fetchUserProfile()
       if let uuid = profileData.uuid, let name = profileData.name {
            self.loggerMixpanel.log("Sending profile data to Mixpanel for: \(name)")
            
            // Get device ID for distinctId
            let deviceID =  await UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            
            // Use CoreData UUID for user_id
            self.setUserProfile(
                distinctId: deviceID,
                userId: uuid,
                name: name
            )
        } else {
            self.loggerCoreData.error("No profile found in CoreData")
        }
        
    }
    
    private func setUserProfile(distinctId: String, userId: UUID, name: String) {
           Mixpanel.mainInstance().identify(distinctId: distinctId)
           Mixpanel.mainInstance().people.set(properties: [
               "$name": name,
               "$user_id": userId.uuidString
           ])
       }
    
}
