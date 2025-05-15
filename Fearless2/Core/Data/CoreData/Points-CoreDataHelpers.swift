//
//  Points-CoreDataHelpers.swift
//  Fearless2
//

import Foundation

extension Points {
    
    var pointsId: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }

}

