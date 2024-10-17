//
//  Section-CoreDataHelpers.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/14/24.
//

import Foundation

extension Section {
    
    var sectionId:UUID {
        get { id ?? UUID()}
        set { id = newValue}
    }
    
    var sectionTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    
    var sectionCategory: String {
        get { category ?? "" }
        set { category = newValue }
    }
    
    var sectionTopic: Topic? {
        topic
    }
    
    var sectionQuestions: [Question] {
        let result = questions?.allObjects as? [Question] ?? []
        return result
    }
    
}
