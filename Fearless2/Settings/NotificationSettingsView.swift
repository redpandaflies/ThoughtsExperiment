//
//  NotificationSettingsView.swift
//  TrueBlob
//
//  Created by Yue Deng-Wu on 2/22/24.
//

import Mixpanel
import SwiftUI

struct NotificationSettingsView<S: ShapeStyle>: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    @State private var showPermissionAlert: Bool = false
    @State private var alertMessage: String = ""
    
    let backgroundColor: S
    
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
                    Text("Daily spark reminder")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColors.textPrimary)

                    Text("Never miss out on your topic of the day.")
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
        .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
            Button("Go to Settings") {
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Notifications are disabled in system settings. To receive daily reminders, please enable notifications for this app.")
        }
        .onAppear {
            // check notification status, in case user turned off notifications in phone settings
            checkNotificationStatus()
        }
        
    }
}

private extension NotificationSettingsView {
    
    private func checkNotificationStatus() {
        Task {
            let settings = await notificationManager.getNotificationSettings()
                        
            if settings.authorizationStatus == .denied {
                await MainActor.run {
                    self.isScheduled = false
                    self.alertMessage = "Notifications are disabled in system settings. To receive daily reminders, please enable notifications for this app."
                    self.showPermissionAlert = true
                }
                return
            }
            
        }
    }
    
    // Handle if the user turned on/off the daily reminder feature
    private func handleIsScheduledChange(isScheduled: Bool) {
        if isScheduled {
            Task {
                let settings = await notificationManager.getNotificationSettings()
                            
                if settings.authorizationStatus == .denied {
                    await MainActor.run {
                        self.isScheduled = false
                        self.alertMessage = "Notifications are disabled in system settings. To receive daily reminders, please enable notifications for this app."
                        self.showPermissionAlert = true
                    }
                    return
                }

                do {
                    try await notificationManager.requestAuthorization()
                    notificationManager.scheduleDailyNotifications(notificationTimeString: notificationTimeString)
                    DispatchQueue.global(qos: .background).async {
                        Mixpanel.mainInstance().track(event: "Set daily reminder")
                    }
                } catch {
                    await MainActor.run {
                        self.isScheduled = false
                        self.alertMessage = "Failed to request notification permission."
                        self.showPermissionAlert = true
                    }
                }
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

