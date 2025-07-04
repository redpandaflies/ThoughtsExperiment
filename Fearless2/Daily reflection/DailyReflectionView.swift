//
//  DailyReflectionView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/4/25.
//
import CoreData
import Mixpanel
import SwiftUI


struct DailyReflectionView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var dailyTopicViewModel: DailyTopicViewModel
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    @State private var selectedTab: Int = 1
    @State private var showUpdateTopicView: Bool = false
    /// notification
    @State private var notificationsScheduled: Bool = false // updated after checking system to see if notification has been scheduled
    @State private var showPermissionAlert: Bool = false
    @State private var alertMessage: String = ""
    
    //LottieView for loading view
    @State private var animationSpeed: CGFloat = 1.0
    @State private var play: Bool = false
    
    // true if user taps on dive deeper button
    @State private var diveDeeper: Bool = false
    
    @Binding var selectedTabHome: TabBarItemHome
    
    @ObservedObject var topic: TopicDaily
    let topicIndex: Int
    let hasTopicForTomorrow: Bool
    let frameWidth: CGFloat
    let backgroundColor: LinearGradient
    let retryActionCreateTopic: () -> Void
    let retryActionCreateTopicQuestions: () -> Void
    
    let screenHeight: CGFloat = UIScreen.current.bounds.height
    
    // Save the state of the toggle on/off for daily reminder
    @AppStorage("isScheduled") var isScheduled = false
    // Save the notification time set by user for daily reminder
    @AppStorage("notificationTimeString") var notificationTimeString = DateFormatter.reminderFormat.string(from: {
        var components = DateComponents()
        components.hour = 9 // 9 AM in 24-hour format
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }())
    
    init(
        dailyTopicViewModel: DailyTopicViewModel,
        topicViewModel: TopicViewModel,
        selectedTabHome: Binding<TabBarItemHome>,
        topic: TopicDaily,
        topicIndex: Int,
        hasTopicForTomorrow: Bool,
        frameWidth: CGFloat,
        backgroundColor: LinearGradient,
        retryActionCreateTopic: @escaping () -> Void,
        retryActionCreateTopicQuestions: @escaping () -> Void
       
    ) {
        self.dailyTopicViewModel = dailyTopicViewModel
        self.topicViewModel = topicViewModel
        self._selectedTabHome = selectedTabHome
        self.topic = topic
        self.topicIndex = topicIndex
        self.hasTopicForTomorrow = hasTopicForTomorrow
        self.frameWidth = frameWidth
        self.backgroundColor = backgroundColor
        self.retryActionCreateTopic = retryActionCreateTopic
        self.retryActionCreateTopicQuestions = retryActionCreateTopicQuestions
       
        // seed from AppStorage so initial UI matches what you last stored
        _notificationsScheduled = State(initialValue: isScheduled)
        
    }
    
    var body: some View {
      
       
            VStack {
                showPill()
                
                switch selectedTab {
                    
                case 0:
                    // loading view
                    loadingView
                        .onAppear {
                            play = true
                        }
                        .onDisappear {
                            play = false
                        }
                    
                case 1:
                    // ready view
                    DailyTopicReadyView(
                        topic: topic,
                        isScheduled: notificationsScheduled,
                        startAction: {
                            diveDeeper = false
                            showUpdateTopicView = true
                        },
                        reviewAction: {
                            diveDeeper = false
                            showUpdateTopicView = true
                        },
                        remindAction: {
                            handleIsScheduledChange(at: notificationTimeString)
                        },
                        diveDeeperAction: {
                            diveDeeper = true
                            showUpdateTopicView = true
                        },
                        goToTopicAction: {
                            topicViewModel.currentGoal = topic.goal
                            selectedTabHome = .topics
                        }
                    )
                    
                
                default:
                    FocusAreaRetryView(action: {
                        retryActionCreateTopic()
                    })
                    
                    
                }
                
            }
            .padding(.horizontal)
            .padding(.vertical)
            .frame(width: frameWidth, height: 350, alignment: .top)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.whiteDefault.opacity(0.1), lineWidth: 0.5)
                    .fill(AppColors.boxGrey6.opacity(0.5))
                    .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 3)
                    .blendMode(.colorDodge)
                
            }
            .task {
                /// check if notifications has been set (in case user turned off notifications in settings and now appstorage var isScheduled state is outdated)
                if topic.topicStatus == TopicStatusItem.locked.rawValue {
                    checkNotificationStatus()
                }
            }
            .onChange(of: isScheduled) {
                if topic.topicStatus == TopicStatusItem.locked.rawValue {
                    checkNotificationStatus()
                }
            }
            .onAppear {
                if topic.topicId == dailyTopicViewModel.currentTopic?.topicId {
                    manageView()
                } else {
                    if selectedTab != 1 {
                        selectedTab = 1
                    }
                }
            }
            .onChange(of: dailyTopicViewModel.createTopic) {
                if topic.topicId == dailyTopicViewModel.currentTopic?.topicId {
                    manageView()
                }
            }
            .onChange(of: showUpdateTopicView) {
                if !showUpdateTopicView {
                    if let _ = topicViewModel.currentGoal {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            selectedTabHome = .topics
                        }
                    }
                    
                    if !hasTopicForTomorrow {
                        Task {
                            let _ = await dailyTopicViewModel.createDailyTopic(topicDate: getNextDayString())
                        }
                    }
                }  
            }
           .fullScreenCover(isPresented: $showUpdateTopicView, onDismiss: {
               showUpdateTopicView = false
           }) {
               UpdateDailyTopicView(
                topicViewModel: topicViewModel,
                dailyTopicViewModel: dailyTopicViewModel,
                showUpdateTopicView: $showUpdateTopicView,
                topic: topic,
                hasTopicForTomorrow: hasTopicForTomorrow,
                backgroundColor: backgroundColor,
                retryActionQuestions: {
                    retryActionCreateTopicQuestions()
                },
                startDiveDeeperFlow: diveDeeper
               )
           }
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
    
    private func showPill() -> some View {
        Text(getPillText)
            .font(.system(size: 15, weight: .light).smallCaps())
            .foregroundStyle(AppColors.textGrey1)
            .fontWidth(.condensed)
            .blendMode(.colorDodge)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(
                        AppColors.boxGrey3.opacity(0.25)
                            .blendMode(.multiply)
                            .shadow(.inner(color: .black.opacity(0.5), radius: 5, x: 0, y: 2))
                            .shadow(.drop(color: .white.opacity(0.2), radius: 0, x: 0, y: 1))
                    )
            }
        
    }
    
    var getPillText: String {
        switch selectedTab {
        case 0:
            return "Generating spark"
        case 1:
            if topic.topicStatus == TopicStatusItem.completed.rawValue {
                return  "Spark Complete"
            } else if topic.topicStatus == TopicStatusItem.locked.rawValue {
                return notificationsScheduled ? "New spark tomorrow" : "Don't miss out"
            }
            return  "Suggested for you"
        default:
            return "Suggested for you"
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack {
            LottieView(
                name: "spinnerAnimatedLoop",
                animationSpeed: $animationSpeed,
                play: $play
            )
            .aspectRatio(contentMode: .fit)
            .frame(width: 90, height: 90)
            .padding(.bottom, 40)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .onAppear {
            play = true
        }
        .onDisappear {
            play = false
        }
    }
    

}


// MARK: - business logic

extension DailyReflectionView {
    
    private func checkNotificationStatus() {
        Task {
            let actual = await notificationManager.checkIfNotificationsAreScheduled()
            
            await MainActor.run {
                if actual != notificationsScheduled {
                    notificationsScheduled = actual
                }
                if isScheduled != actual {
                    isScheduled = actual
                }
            }
        }
    }
    
    private func manageView() {
        switch dailyTopicViewModel.createTopic {
        case .loading:
            selectedTab = 0
        case .ready:
            // show retry if daily topic is empty because API call failed
            if !isDailyTopicFromTomorrow(topic) && topic.topicTitle.isEmpty {
                selectedTab = 2
            } else {
                selectedTab = 1
            }
        case .retry:
            selectedTab = 2
            
        }
    }
    
    private func startTopic() {
        showUpdateTopicView = true
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Started daily topic")
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
                
                await MainActor.run {
                    self.isScheduled = true
                }
                
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
    
    private func goToRelatedTopic() {
        
    }
    
}



