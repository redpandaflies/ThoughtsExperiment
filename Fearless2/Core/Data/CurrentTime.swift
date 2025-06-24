//
//  CurrentTime.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation

func getCurrentTimeString() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"

    let dateString = formatter.string(from: date)
    return dateString
}

func getNextDayString() -> String {
    let calendar = Calendar.current
    let today = Date()
    
    // Add one day
    if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        
        return formatter.string(from: tomorrow)
    }
    
    return ""
}
