//
//  TopicBreak-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//

import Foundation

extension TopicBreak {
    
    var breakId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var breakContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
    
}
