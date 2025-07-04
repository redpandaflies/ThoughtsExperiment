//
//  DailyTopicReadyView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/22/25.
//

/// this view accounts for multiple states: active topic, completed topic, locked topic with & without notifications set, older generated topics that are incomplete (no status saved)

import SwiftUI

struct DailyTopicReadyView: View {
    
    @State private var playAnimation: Bool = false
    
    let topic: TopicDaily
    let isScheduled: Bool  // if daily reminder is set
    let startAction: () -> Void
    let reviewAction: () -> Void
    let remindAction: () -> Void
    let diveDeeperAction: () -> Void
    let goToTopicAction: () -> Void
    
    // notification time set by user for daily reminder
    @AppStorage("notificationTimeString") var notificationTimeString = DateFormatter.reminderFormat.string(from: {
        var components = DateComponents()
        components.hour = 9 // 9 PM in 24-hour format
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }())
    
    var displayNotificationTime: String {
        guard
            let date = DateFormatter.reminderFormat.date(from: notificationTimeString)
        else {
            // Fallback if something’s wrong
            return notificationTimeString
        }

        let minute = Calendar.current.component(.minute, from: date)
        if minute == 0 {
            return DateFormatter.hourOnlyFormat.string(from: date)
        } else {
            return DateFormatter.hourMinuteFormat.string(from: date)
        }
    }
    

    var body: some View {
        VStack(spacing: 15) {
            switch TopicStatusItem(rawValue: topic.topicStatus) ?? .active {
            case .locked:
                lockedBody
            default:
                titlesBody
            }

            RectangleButtonPrimary(
                buttonText: buttonText,
                action: buttonAction,
                imageName: buttonImage,
//                disableMainButton: topic.topicStatus == TopicStatusItem.locked.rawValue && isScheduled,
                sizeSmall: topic.topicStatus == TopicStatusItem.locked.rawValue && isScheduled,
                buttonColor: buttonColor,
                cornerRadius: 10,
                showDiveDeeperButton: topic.topicStatus == TopicStatusItem.completed.rawValue ? true : false,
                diveDeeperButtonState: topic.goal != nil ? .goToTopic : .diveDeeper,
                diveDeeperAction: {
                    topic.goal != nil ? goToTopicAction() : diveDeeperAction()
                }
            )

            if topic.topicStatus != TopicStatusItem.completed.rawValue && topic.topicStatus != TopicStatusItem.locked.rawValue {
                HStack(spacing: 3) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 13, weight: .light).smallCaps())
                        .foregroundStyle(AppColors.textPrimary.opacity(0.6))
                        .fontWidth(.condensed)
                    Text("2 min")
                        .font(.system(size: 13, weight: .light).smallCaps())
                        .foregroundStyle(AppColors.textPrimary.opacity(0.6))
                        .fontWidth(.condensed)
                }
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var lockedBody: some View {
        VStack {
            if isScheduled {
                LottieView(
                    name: "spinnerAnimatedNoColor",
                    loopMode: .playOnce,
                    animationSpeed: .constant(1.0),
                    play: $playAnimation
                )
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .blendMode(.luminosity)
                .padding(.top, 20)
                .onAppear {
                   playAnimation = true
                }
               .onDisappear {
                 
                   playAnimation = false
               }
          
            } else {
                Image("notificationsBell")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 121, height: 117)
                    .blendMode(.plusLighter)
                    .padding(.bottom, 10)
                   
            }
               
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var titlesBody: some View {
        VStack (spacing: 10) {
            Text(topic.topicEmoji)
                .font(.system(size: 35, weight: .medium, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.top, 20)

            Text(topic.topicTitle)
                .multilineTextAlignment(.center)
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(.horizontal, 25)
    }

    // MARK: - Button Logic
    private var buttonText: String {
        switch TopicStatusItem(rawValue: topic.topicStatus) {
        case .active:
            return "Start"
        case .completed:
            return "Review"
        case .locked:
            return isScheduled ? "I'll remind you at \(displayNotificationTime) tomorrow" : "Set reminder for tomorrow"
        default:
            return "Start"
        }
    }

    private func buttonAction() {
        switch TopicStatusItem(rawValue: topic.topicStatus) {
        case .active:
            startAction()
        case .completed:
            reviewAction()
        case .locked:
            if !isScheduled {
                remindAction()
            }
        default:
            startAction()
        }
    }

    private var buttonImage: String {
        switch TopicStatusItem(rawValue: topic.topicStatus) {
        case .locked:
            return isScheduled ? "bell.fill" : ""
        case .completed:
            return "book.pages.fill"
        default:
            return ""
        }
    }

    private var buttonColor: RectangleButtonColor {
        switch TopicStatusItem(rawValue: topic.topicStatus) {
        case .active:
            return .white
        case .completed:
            return .blendDark
        case .locked:
            return isScheduled ? .clearNoStroke : .yellow
        default:
            return .white
        }
    }
}



