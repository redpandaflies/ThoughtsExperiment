//
//  DateFormatter.swift
//  Tinyverse
//
//  Created by Yue Deng-Wu on 10/22/24.
//

import Foundation
import SwiftUI


//MARK: Dates
extension DateFormatter {
    static let incomingFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

extension DateFormatter {
    static let displayFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
    
    static func displayString(from date: Date) -> String {
            return DateFormatter.displayFormat.string(from: date).uppercased()
    }
}

extension DateFormatter {
    static let incomingFormat2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

extension DateFormatter {
    static let displayFormat2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    static func displayString2(from date: Date) -> String {
            return DateFormatter.displayFormat2.string(from: date).capitalized
    }
}
