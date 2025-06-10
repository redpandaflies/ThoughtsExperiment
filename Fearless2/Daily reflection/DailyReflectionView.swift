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
    @StateObject var dailyTopicViewModel: DailyTopicViewModel
    
    @State private var selectedTab: Int = 1
    @State private var showSettingsView: Bool = false
    @State private var showLaurelInfoSheet: Bool = false
    @State private var showUpdateTopicView: Bool = false
    
    //LottieView
    @State private var animationSpeed: CGFloat = 1.0
    @State private var play: Bool = false
    
    let currentPoints: Int
    
    let backgroundColor: LinearGradient = LinearGradient(
        stops: [
        Gradient.Stop(color: AppColors.backgroundDaily1, location: 0.00),
        Gradient.Stop(color: AppColors.backgroundDaily3, location: 0.60),
        Gradient.Stop(color: AppColors.backgroundDaily3, location: 1.00),
        ],
        startPoint: UnitPoint(x: 0, y: 0),
        endPoint: UnitPoint(x: 0.80, y: 1)
    )
    
    let screenWidth: CGFloat = UIScreen.current.bounds.width
    let screenHeight: CGFloat = UIScreen.current.bounds.height
    
    @FetchRequest(
        entity: TopicDaily.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \TopicDaily.createdAt, ascending: false)
        ]
    ) var dailyTopics: FetchedResults<TopicDaily>
    
    
    init(
           dailyTopicViewModel: DailyTopicViewModel,
           currentPoints: Int
       ) {
           _dailyTopicViewModel = StateObject(wrappedValue: dailyTopicViewModel)
           self.currentPoints = currentPoints
       }
    
    var body: some View {
        NavigationStack {
            VStack {
                
              
                if selectedTab == 1 {
                    if let topic = dailyTopics.first {
                        getHeading(topic)
                            .padding(.bottom, 20)
                    }
                }
                
                VStack {
                    showPill()
                    
                    switch selectedTab {
                        
                    case 0:
                        // loading view
                        loadingView()
                            .onAppear {
                                play = true
                            }
                            .onDisappear {
                                play = false
                            }
                        
                    case 1:
                        // ready view
                        if let topic = dailyTopics.first {
                            readyView(topic)
                        }
                    
                    default:
                        FocusAreaRetryView(action: {
                            createDailyTopic()
                        })
                        
                        
                    }
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                .frame(width: screenWidth * 0.81, height: 350, alignment: .top)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.whiteDefault.opacity(0.1), lineWidth: 0.5)
                        .fill(AppColors.boxGrey6.opacity(selectedTab == 0 ? 0.2 : 0.5))
                        .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 3)
                        .blendMode(.colorDodge)
                    
                }
                .padding(.bottom, 20)
              
                getFooter(dailyTopics.first)
                    .padding(.bottom, screenHeight * 0.27)
                
            }// VStack
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .background {
                BackgroundPrimary(
                    backgroundColor: backgroundColor
                )
                
            }
            .onAppear {
                createDailyTopicIfNeeded()
            }
            .onChange(of: dailyTopicViewModel.createTopic) {
                switch dailyTopicViewModel.createTopic {
                case .loading:
                    selectedTab = 0
                case .ready:
                    selectedTab = 1
                case .retry:
                    selectedTab = 2
                    
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    SettingsToolbarItem(action: {
                        showSettingsView = true
                    })
                   
                }
                
                if FeatureFlags.isStaging {
                    ToolbarItem(placement: .principal) {
                        
                        Button {
                            createDailyTopic()
                        } label: {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 17, weight: .thin))
                                .foregroundStyle(AppColors.textPrimary)
                        }
                        
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                       Button {
                           // show sheet explaining points
                           showLaurelInfoSheet = true
                           
                           DispatchQueue.global(qos: .background).async {
                               Mixpanel.mainInstance().track(event: "Tapped laurel counter")
                           }

                       } label: {
                           LaurelItem(size: 15, points: "\(currentPoints)")
                       }
                   }
                
            }
            .sheet(isPresented: $showSettingsView, onDismiss: {
                showSettingsView = false
            }, content: {
                SettingsView(backgroundColor: backgroundColor)
                    .presentationCornerRadius(20)
                    .presentationBackground {
                        Color.clear
                            .background(.regularMaterial)
                    }
            })
            .sheet(isPresented: $showLaurelInfoSheet, onDismiss: {
                   showLaurelInfoSheet = false
               }) {
               InfoPrimaryView (
                backgroundColor: backgroundColor,
                   useIcon: false,
                   titleText: "You earn laurels by answering questions and resolving topics.",
                   descriptionText: "You'll soon be able to use them to unlock new abilities.",
                   useRectangleButton: false,
                   buttonAction: {}
               )
               .presentationDetents([.fraction(0.65)])
               .presentationCornerRadius(30)
           }
               .fullScreenCover(isPresented: $showUpdateTopicView, onDismiss: {
                   showUpdateTopicView = false
               }) {
                   if let topic = dailyTopics.first {
                       UpdateDailyTopicView(
                        dailyTopicViewModel: dailyTopicViewModel,
                        showUpdateTopicView: $showUpdateTopicView,
                        topic: topic,
                        backgroundColor: backgroundColor,
                        retryActionQuestions: {
                            Task {
                                await createTopicQuestions(topic)
                            }
                        }
                       )
                   }
                       
               }
            
        }//NavigationStack
    }
    
    
    private func getHeading(_ topic: TopicDaily) -> some View {
        
        VStack (spacing: 5){
            Text("Today's theme")
                .font(.system(size: 17, weight: .light).smallCaps())
                .foregroundStyle(AppColors.textPrimary.opacity(0.6))
                .fontWidth(.condensed)
            
            Text(topic.topicTheme)
                .font(.system(size: 19, design: .serif).smallCaps())
                .foregroundStyle(AppColors.textPrimary)
                .kerning(0.95)
            
        }
        
    }
    
    private func showPill() -> some View {
        Text(getPillText())
            .font(.system(size: 15, weight: .light).smallCaps())
            .foregroundStyle(AppColors.textPrimary)
            .fontWidth(.condensed)
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
    
    private func getPillText() -> String {
        switch selectedTab {
        case 0:
            return "Generating topic"
        case 1:
            if let topic = dailyTopics.first, topic.topicStatus == TopicStatusItem.completed.rawValue {
                return  "Topic Complete"
            }
            return  "Suggested for you"
        default:
            return "Suggested for you"
        }
    }
    
    private func loadingView() -> some View {
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
    
    
    private func readyView(_ topic: TopicDaily) -> some View {
        VStack (spacing: 15) {
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
            
            if topic.topicStatus != TopicStatusItem.completed.rawValue {
                RectangleButtonPrimary(
                    buttonText: "Start",
                    action: {
                        startTopic()
                    },
                    buttonColor: .white,
                    cornerRadius: 10
                )
            } else {
                RoundButtonWithEmoji(
                    symbol: "book.pages.fill",
                    buttonAction: {
                        showUpdateTopicView = true
                    }
                )
                .padding(.bottom)
            }
            
            if topic.topicStatus != TopicStatusItem.completed.rawValue {
                HStack (spacing: 3) {
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
    
    private func getFooter(_ topic: TopicDaily?) -> some View {
        let isVisible = (topic?.topicStatus == TopicStatusItem.completed.rawValue && selectedTab == 1)
        
        return Text("Come back tomorrow for more.")
            .font(.system(size: 15, weight: .light))
            .foregroundStyle(isVisible ? AppColors.textPrimary.opacity(0.6) : .clear)
            .fontWidth(.condensed)
    }
    
    private func createDailyTopicIfNeeded() {
        
        guard let latest = dailyTopics.first else {
               createDailyTopic()
               return
           }

       if !isLatestDailyTopicFromToday(latest) {
           createDailyTopic()
       } else {
           selectedTab = 1
       }
    
    }
    
    // check if current date matches date of latest daily topic created
    private func isLatestDailyTopicFromToday(_ topic: TopicDaily?) -> Bool {
        guard let createdAtString = topic?.createdAt else { return false }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // assuming saved in GMT

        guard let createdAtDate = formatter.date(from: createdAtString) else {
            return false
        }

        // Convert both to local calendar components
        let calendar = Calendar.current
        let now = Date()

        let topicComponents = calendar.dateComponents([.year, .month, .day], from: createdAtDate)
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)

        return topicComponents == todayComponents
    }
    
    private func createDailyTopic() {
        
        Task {
            do {
                try await dailyTopicViewModel.manageRun(selectedAssistant: .topicDaily)
            } catch {
                dailyTopicViewModel.createTopic = .retry
            }
            
            await createTopicQuestions(dailyTopicViewModel.currentTopic)
        }
 
    }
    
    private func createTopicQuestions(_ topic: TopicDaily?) async {
        do {
            try await dailyTopicViewModel.manageRun(selectedAssistant: .topicDailyQuestions, topic: topic)
        } catch {
            dailyTopicViewModel.createTopicQuestions = .retry
        }
    }
    
    private func startTopic() {
        showUpdateTopicView = true
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Started daily topic")
        }
    }

}


