//
//  NotificationsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/17/25.
//
import Mixpanel
import SwiftUI

enum BoxStyle{
    case light
    case dark
    case yellow
}

struct NotificationsView: View {
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var showPermissionAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // Save the state of the toggle on/off for daily reminder in NotificationSettingsView
    @AppStorage("isScheduled") var isScheduled = false
    // Save the notification time set by user for daily reminder
    @AppStorage("notificationTimeString") var notificationTimeString = DateFormatter.reminderFormat.string(from: {
        var components = DateComponents()
        components.hour = 21 // 9 PM in 24-hour format
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }())
    
    let leftAction: () -> Void
    let rightAction: () -> Void
    
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        
        VStack (spacing: 10){
            Image("notificationsBell")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 175, height: 175)
                .blendMode(.plusLighter)
                .padding(.bottom, 10)
            
            Text("Turn on reminders")
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
            
            Text("Let's make sure you never miss\nyour daily spark.")
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                .lineSpacing(1.4)
                .padding(.bottom)
            
            HStack {
                ButtonSquare(
                    title: "Not now",
                    buttonColor: .dark,
                    leftSymbol: "xmark",
                    height: screenWidth * 0.43
                )
                .onTapGesture {
                    leftAction()
                }
                
                ButtonSquare(
                    title: "Remind me",
                    buttonColor: .yellow,
                    height: screenWidth * 0.43
                )
                .onTapGesture {
                    rightAction()
                    handleIsScheduledChange(at: notificationTimeString)
                }
                
            }
    
        }
        .padding(.horizontal)
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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
    }
    
    private func handleIsScheduledChange(at timeString: String) {
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
                notificationManager.scheduleDailyNotifications(notificationTimeString: timeString)
                self.isScheduled = true
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
      
    }
}

struct ButtonSquare: View {
    let title: String
    let subtitle: String
    let buttonColor: BoxStyle
    let leftSymbol: String
    let rightSymbol: String
    let height: CGFloat

    let screenWidth = UIScreen.current.bounds.width

    init(
        title: String,
        subtitle: String = "",
        buttonColor: BoxStyle,
        leftSymbol: String = "arrow.right",
        rightSymbol: String = "checkmark",
        height: CGFloat
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonColor = buttonColor
        self.leftSymbol = leftSymbol
        self.rightSymbol = rightSymbol
        self.height = height
    }

    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .font(.system(size: 21, weight: buttonColor == .yellow ? .regular : .light))
                .fontWidth(.condensed)
                .foregroundStyle(buttonColor == .yellow ? Color.black : AppColors.textPrimary)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.system(size: 17, weight: .light))
                    .fontWidth(.condensed)
                    .foregroundStyle(buttonColor == .yellow ? Color.black : AppColors.textPrimary)
                    .opacity(0.5)
            }

            Spacer()

            RoundButton(
                buttonImage: buttonColor == .yellow ? rightSymbol : leftSymbol,
                buttonColor: buttonColor == .yellow ? .white : .dark
            )
            .disabled(true)
        }
        .padding(.horizontal)
        .padding(.vertical, 30)
        .frame(width: screenWidth * 0.43, height: height)
        .contentShape(RoundedRectangle(cornerRadius: 26))
        .background {
            RoundedRectangle(cornerRadius: 26)
                .stroke(AppColors.strokePrimary.opacity(0.10), lineWidth: 0.5)
                .fill(AnyShapeStyle(backgroundColor(buttonColor)))
                .shadow(
                    color: shadowProperties(buttonColor).color,
                    radius: shadowProperties(buttonColor).radius,
                    x: 0,
                    y: shadowProperties(buttonColor).y
                )
                .blendMode(buttonColor == .yellow ? .normal : .colorDodge)
        }
    }

    private func backgroundColor(_ buttonColor: BoxStyle) -> any ShapeStyle {
        switch buttonColor {
        case .yellow:
            return LinearGradient(
                gradient: Gradient(colors: [AppColors.boxYellow1, AppColors.boxYellow2]),
                startPoint: .top,
                endPoint: .bottom
            )
        default:
            return AppColors.boxGrey1.opacity(0.3)
        }
    }

    private func shadowProperties(_ buttonColor: BoxStyle) -> (color: Color, radius: CGFloat, y: CGFloat) {
        switch buttonColor {
        case .yellow:
            return (Color.black.opacity(0.05), 5, 2)
        default:
            return (Color.black.opacity(0.30), 15, 3)
        }
    }
}
