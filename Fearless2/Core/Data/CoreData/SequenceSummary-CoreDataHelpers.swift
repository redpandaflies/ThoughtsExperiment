//
//  SequenceSummary-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/23/24.
//

import Foundation

extension SequenceSummary {
    var summaryId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var summaryCreatedAt: String {
        get { createdAt ?? "" }
        set { createdAt = newValue }
    }
    
    var summaryContent: String {
        get { content ?? "" }
        set { content = newValue }
    }
    
}
