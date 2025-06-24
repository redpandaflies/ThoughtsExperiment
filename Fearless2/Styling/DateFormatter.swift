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

//notification date format
extension DateFormatter {
    static let reminderFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
   
    // Formats as "9 PM" (no minutes)
    static let hourOnlyFormat: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h a"                // e.g. "9 PM"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    // Formats as "9:04 PM" (with minutes)
    static let hourMinuteFormat: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"             // e.g. "9:04 PM"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}

// MARK: - check dates of daily topics

/// Converts a TopicDaily’s `createdAt` into a Date.
func parseTopicDate(_ topic: TopicDaily?) -> Date? {
    guard let dateString = topic?.createdAt else { return nil }
    return DateFormatter.incomingFormat.date(from: dateString)
}

/// Returns true if the topic’s date is in today’s calendar day.
func isDailyTopicFromToday(_ topic: TopicDaily?) -> Bool {
    guard let date = parseTopicDate(topic) else { return false }
    return Calendar.current.isDateInToday(date)
}

/// Returns true if the topic’s date is tomorrow.
func isDailyTopicFromTomorrow(_ topic: TopicDaily?) -> Bool {
    guard let date = parseTopicDate(topic) else { return false }
    return Calendar.current.isDateInTomorrow(date)
}

/// Returns true if the topic’s date is strictly before today’s start.
func isLatestDailyTopicBeforeToday(_ topic: TopicDaily?) -> Bool {
    guard let date = parseTopicDate(topic) else { return false }
    let startOfToday = Calendar.current.startOfDay(for: Date())
    return date < startOfToday
}
