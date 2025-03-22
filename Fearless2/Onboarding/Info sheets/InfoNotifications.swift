//
//  InfoNotifications.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/27/25.
//
import Mixpanel
import SwiftUI

struct InfoNotifications: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    let backgroundColor: Color
    
    let screenHeight = UIScreen.current.bounds.height
 
    // Save the state of the toggle on/off for daily reminder in NotificationSettingsView
    @AppStorage("isScheduled") var isScheduled = false
    // Save the notification time set by user for daily reminder
    @AppStorage("notificationTimeString") var notificationTimeString = DateFormatter.reminderFormat.string(from: {
        var components = DateComponents()
        components.hour = 21 // 9 PM in 24-hour format
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }())
    @AppStorage("seenNotificationsInfoSheet") var seenNotificationsInfoSheet: Bool = false
    
    var body: some View {
        VStack(spacing: 5) {
            
            HStack {
                
                Spacer()
                
                Button {
                    dismiss()
                    seenNotificationsInfoSheet = true
                } label: {
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 25))
                        .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                    
                }
            }
            .padding(.vertical)
            
            Image(systemName: "clock.fill")
                .font(.system(size: 40))
                .padding(.bottom, 20)

            Text("When's the best time for you\nto explore the realms?")
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom, 10)
            
            Text("We recommend exploring before bed to\nreflect and wind down.")
                .multilineTextAlignment(.center)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 40)
             
            VStack {
                DatePicker("" ,selection: Binding(
                    get: {
                        // Get the notification time schedule set by user
                        DateFormatter.reminderFormat.date(from: notificationTimeString) ?? Date()
                    },
                    set: {
                        // On value set, change the notification time
                        notificationTimeString = DateFormatter.reminderFormat.string(from: $0)
                        
                    }
                ), displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
            }
            .frame(height: 200)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            RoundButton(
                buttonImage: "checkmark",
                size: 30,
                frameSize: 80,
                buttonAction: {
                    dismiss()
                    handleIsScheduledChange()
                    seenNotificationsInfoSheet = true
                    isScheduled = true
            })
      
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .frame(maxWidth: .infinity, maxHeight: screenHeight * 0.9, alignment: .top)
        .backgroundSecondary(backgroundColor: backgroundColor, height: screenHeight * 0.9, yOffset: -(screenHeight * 0.1))
        .environment(\.colorScheme, .dark)
    }
    
    private func handleIsScheduledChange() {
        notificationManager.requestAuthorization()
        notificationManager.scheduleDailyNotifications(notificationTimeString: notificationTimeString)
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Set daily reminder")
        }
      
    }
    
}

