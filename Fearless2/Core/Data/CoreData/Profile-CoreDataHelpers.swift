//
//  Profile-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/10/25.
//

import Foundation

extension Profile {
    
    var profileId: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    var profileName: String {
        get { name ?? "" }
        set { name = newValue }
    }
}
