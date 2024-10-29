//
//  Insight-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/28/24.
//

import Foundation

extension Insight {
    var insightId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var insightContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
    
}
