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
    
    enum NotificationError: Error {
        case authorizationDenied
        case authorizationFailed
    }
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    func setupNotifications() async throws {
        do {
            try await requestAuthorization()
        } catch {
            throw NotificationError.authorizationFailed
        }
    }
    
    func requestAuthorization() async throws {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            if !granted {
                throw NotificationError.authorizationDenied
            }
            logger.log("Permissions granted.")
        } catch {
            logger.error("Authorization error: \(error.localizedDescription)")
            throw NotificationError.authorizationFailed
        }
    }
    
    func getNotificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            notificationCenter.getNotificationSettings { settings in
                continuation.resume(returning: settings)
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
        content.body = "Don't miss out on the topic of the day!"
        content.sound = UNNotificationSound.default
        
        // Set the notification to repeat daily
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
    }
    
    
    //for handling user interaction with notification (e.g. pop up recording sheet when they tap on notification to open app)
    
//        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//            DispatchQueue.main.async {
//                print("Setting ShowRecordingView to true")
//                UserDefaults.standard.set(true, forKey: "ShowRecordingView")
//            }
//            completionHandler()
//        }
    
        // check if daily reminder has been set
    func checkIfNotificationsAreScheduled() async -> Bool {
        let requests = await notificationCenter.pendingNotificationRequests()
        if FeatureFlags.isStaging {
            for request in requests {
                logger.log("Scheduled: \(request.identifier)")
            }
        }
        return requests.contains { $0.identifier == "dailyReminder" }
    }

}
