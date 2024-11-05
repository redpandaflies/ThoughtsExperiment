//
//  FocusArea-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/3/24.
//

import Foundation

extension FocusArea {
    var focusAreaId: UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var focusAreaCreatedAt: String {
        get { createdAt ?? "" }
        set { createdAt = newValue }
    }
    
    var focusAreaTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var focusAreaReasoning: String {
        get { reasoning ?? "" }
        set { reasoning = newValue }
    }
    
    var focusAreaSections: [Section] {
        let result = sections?.allObjects as? [Section] ?? []
        return result
    }

    var focusAreaEntries: [Entry] {
        let result = entries?.allObjects as? [Entry] ?? []
        return result
    }
}
