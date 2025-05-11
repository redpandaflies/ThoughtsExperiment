//
//  NotificationSettingsView.swift
//  TrueBlob
//
//  Created by Yue Deng-Wu on 2/22/24.
//

import Mixpanel
import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    let backgroundColor: Color
    
    // Save the state of the toggle on/off for daily reminder
    @AppStorage("isScheduled") var isScheduled = false
    // Save the notification time set by user for daily reminder
    @AppStorage("notificationTimeString") var notificationTimeString = DateFormatter.reminderFormat.string(from: {
        var components = DateComponents()
        components.hour = 21 // 9 PM in 24-hour format
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }())

    var body: some View {

        VStack {
            Toggle(isOn: $isScheduled) {
                VStack (alignment: .leading, spacing: 2){
                    Text("Daily reminder")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Make progress on what keeps you up at night")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(AppColors.textPrimary)
                        .opacity(0.5)
                       
                }
                .padding(.vertical, 5)
            }
            .tint(Gradient(colors: [AppColors.buttonYellow1, AppColors.buttonYellow2]))
            .onChange(of: isScheduled) {
                handleIsScheduledChange(isScheduled: isScheduled)
            }

            if isScheduled {
                VStack {
                    DatePicker("" ,selection: Binding(
                        get: {
                            // Get the notification time schedule set by user
                            DateFormatter.reminderFormat.date(from: notificationTimeString) ?? Date()
                        },
                        set: {
                            // On value set, change the notification time
                            notificationTimeString = DateFormatter.reminderFormat.string(from: $0)
                            handleNotificationTimeChange()
                        }
                    ), displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    
                }
                .frame(height: 200)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                

            }

              
        }//VStack
        .padding(.horizontal, 30)
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor: backgroundColor)
        }
        .navigationTitle("Reminders")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

private extension NotificationSettingsView {
    // Handle if the user turned on/off the daily reminder feature
    private func handleIsScheduledChange(isScheduled: Bool) {
        if isScheduled {
            notificationManager.requestAuthorization()
            notificationManager.scheduleDailyNotifications(notificationTimeString: notificationTimeString)
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Set daily reminder")
            }
        } else {
            notificationManager.cancelDailyReminder()
        }
    }
    
    // Handle if the notification time changed from DatePicker
    private func handleNotificationTimeChange() {
        notificationManager.cancelDailyReminder()
        notificationManager.scheduleDailyNotifications(notificationTimeString: notificationTimeString)
    }
    
}

