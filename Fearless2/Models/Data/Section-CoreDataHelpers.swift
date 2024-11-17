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
    
    var sectionQuestions: [Question] {
        let result = questions?.allObjects as? [Question] ?? []
        return result
    }
    
    func assignSummary(_ summary: SectionSummary) {
        self.summary = summary
        summary.section = self
    }
}
