//
//  Notifications.swift
//  TrueBlob
//
//  Created by Yue Deng-Wu on 1/30/24.
//

import Foundation
import OSLog
import UserNotifications

// MARK: set Sunday recap reminder
final class NotificationManager: NSObject, ObservableObject {
    
    @Published var selectedDestination: Bool = false
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    let logger = Logger.notificationEvents
    
    static let shared = NotificationManager()
    
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    func setupNotifications() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.logger.log("Permissions granted.")
            } else if let error = error {
                self.logger.log("Authorization error: \(error.localizedDescription)")
            }
        }
    }
    
}

// MARK: for set daily prompt feature
extension NotificationManager: UNUserNotificationCenterDelegate {
    
        // Schedule daily notification at user-selected time
    
        func scheduleDailyNotifications(notificationTimeString: String) {
        
            // Convert the time in string to date
            guard let time = DateFormatter.reminderFormat.date(from: notificationTimeString) else {
                return
            }
          
            let content = UNMutableNotificationContent()
            content.title = "Kaleida"
            content.body = "Let’s figure out that thing that keeps you up at night →."
            content.sound = UNNotificationSound.default
            
            // Set the notification to repeat only on weekdays
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.hour, .minute], from: time)
            
            // Create a single notification that repeats daily
               let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
               let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    self.logger.log("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
        
    
        func cancelDailyReminder() {
              notificationCenter.removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
            
            // Also cancel any previously set weekday reminders
            let weekdayIdentifiers = (2...6).map { "dailyReminder-\($0)" }
            notificationCenter.removePendingNotificationRequests(withIdentifiers: weekdayIdentifiers)
          }
    
    
    //for handling user interaction with notification (e.g. pop up recording sheet when they tap on notification to open app)
    
//        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//            DispatchQueue.main.async {
//                print("Setting ShowRecordingView to true")
//                UserDefaults.standard.set(true, forKey: "ShowRecordingView")
//            }
//            completionHandler()
//        }

}
