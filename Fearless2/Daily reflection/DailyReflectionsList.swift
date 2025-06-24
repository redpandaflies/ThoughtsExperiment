//
//  DailyReflectionsList.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/20/25.
//
import CoreData
import Mixpanel
import SwiftUI

struct DailyReflectionsList: View {
    
    @StateObject var dailyTopicViewModel: DailyTopicViewModel
    @ObservedObject var topicViewModel: TopicViewModel
    
    /// prevents createDailyTopicIfNeeded from being triggered multiple times
    @State private var hasInitiallyAppeared = false
    
    @State private var topicScrollPosition: Int?
    @State private var showSettingsView: Bool = false
    @State private var showLaurelInfoSheet: Bool = false
   
    @Binding var selectedTabHome: TabBarItemHome
    let currentPoints: Int
    
    var currentTopic: TopicDaily? {
        guard dailyTopics.count > 0 else {
            return nil
        }
        return dailyTopics[topicScrollPosition ?? 0]
    }
    
    var latestIsForTomorrow: Bool {
        return isDailyTopicFromTomorrow(dailyTopics.first)
    }
    
    /// topic box size and scroll padding
    let screenWidth: CGFloat = UIScreen.current.bounds.width
    var topicBoxWidth: CGFloat {
        return screenWidth * 0.81
    }
    var safeAreaPadding: CGFloat {
        return (screenWidth - topicBoxWidth)/2
    }
    
    /// background
    let backgroundColor: LinearGradient = LinearGradient(
        stops: [
        Gradient.Stop(color: AppColors.backgroundDaily1, location: 0.00),
        Gradient.Stop(color: AppColors.backgroundDaily3, location: 0.60),
        Gradient.Stop(color: AppColors.backgroundDaily3, location: 1.00),
        ],
        startPoint: UnitPoint(x: 0, y: 0),
        endPoint: UnitPoint(x: 0.80, y: 1)
    )
    
    /// fetch all daily topics
    @FetchRequest(
        entity: TopicDaily.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \TopicDaily.createdAt, ascending: false)
        ]
    ) var dailyTopics: FetchedResults<TopicDaily>
    
    var body: some View {
    
        NavigationStack {
            VStack {
                /// header
                getHeading()
                    .padding(.bottom, 20)
                
                /// reflection box
                ScrollView (.horizontal) {
                    LazyHStack (spacing: 15) {
                        ForEach(Array(dailyTopics.enumerated()), id: \.element.topicId) { index, topic in
                            DailyReflectionView(
                                dailyTopicViewModel: dailyTopicViewModel,
                                topicViewModel: topicViewModel,
                                selectedTabHome: $selectedTabHome,
                                topic: topic,
                                topicIndex: index,
                                hasTopicForTomorrow: latestIsForTomorrow,
                                frameWidth: topicBoxWidth,
                                backgroundColor: backgroundColor,
                                retryActionCreateTopic: {
                                    Task {
                                        await createDailyTopic(topic)
                                    }
                                },
                                retryActionCreateTopicQuestions: {
                                    Task {
                                        await createTopicQuestions(topic)
                                    }
                                }
                            )
                            .id(index)
                            
                        }//ForEach
                        
                    }//HStack
                    .frame(height: 360)
                    .scrollTargetLayout()
                    
                }//Scrollview
                .scrollPosition(id: $topicScrollPosition, anchor: .center)
                .scrollClipDisabled(true)
                .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
                .scrollIndicators(.hidden)
                .contentMargins(.horizontal, safeAreaPadding, for: .scrollContent)
                
                
            }//VStack
            .padding(.top, 50)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                BackgroundPrimary(
                    backgroundColor: backgroundColor,
                    addBlur: true
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                if !hasInitiallyAppeared {
                    hasInitiallyAppeared = true
                    createDailyTopicIfNeeded()
                }
                }
            .onAppear {
                if !hasInitiallyAppeared {
                    hasInitiallyAppeared = true
                    createDailyTopicIfNeeded()
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
                            createNewTopicForToday()
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
            .navigationBarTitleDisplayMode(.inline)
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
        }//NavigationStack
    }
    
    private func getHeading() -> some View {
        
        VStack (spacing: 5){
            
            Text(getTopicDateHeader)
                .font(.system(size: 17, weight: .light).smallCaps())
                .foregroundStyle(AppColors.textPrimary.opacity(0.6))
                .fontWidth(.condensed)
            
            Text(getSubtitle)
                .font(.system(size: 19, design: .serif).smallCaps())
                .foregroundStyle(AppColors.textPrimary)
                .kerning(0.95)
            
        }
        
    }
    
    private var getTopicDateHeader: String {
        
        if let currentTopic = currentTopic, dailyTopics.first?.topicId == currentTopic.topicId {
            if isDailyTopicFromToday(currentTopic) {
                return "Today's theme"
            }/* else if isDailyTopicFromTomorrow(currentTopic) {*/
//                return "Tomorrow's spark"
//            }
        }
        
        return DateFormatter.displayString(from: DateFormatter.incomingFormat.date(from: currentTopic?.topicCreatedAt ?? getCurrentTimeString()) ?? Date())
     
    }
    
    private var getSubtitle: String {
        return currentTopic?.topicStatus == TopicStatusItem.locked.rawValue ? "What will it be?" : currentTopic?.topicTheme ?? "What will it be?"
        
    }
    
}


extension DailyReflectionsList {
    
    private func createDailyTopicIfNeeded() {
        if FeatureFlags.isStaging {
            print("Checking to see if new daily topic is needed")
        }
        /// if there's no daily topic, create one
        guard let latest = dailyTopics.first else {
            createNewTopicForToday()
            return
        }
        
        let latestTopicFromToday = isDailyTopicFromToday(latest)
        let latestTopicFromBefore = isLatestDailyTopicBeforeToday(latest)
       
        if latestTopicFromToday {
            if latest.status == TopicStatusItem.locked.rawValue {
                if dailyTopicViewModel.createTopic != .loading {
                    Task {
                        await createDailyTopic(latest)
                    }
                }
            }
        } else if latestTopicFromBefore {
            /// if the latest daily topic is from before today
            createNewTopicForToday()
        }
        
        /// reset state var
        hasInitiallyAppeared = false
    }
    
    private func createNewTopicForToday() {
        if dailyTopicViewModel.createTopic != .loading {
            
            Task {
                let newTopic = await dailyTopicViewModel.createDailyTopic(topicDate: getCurrentTimeString())
                
                await createDailyTopic(newTopic)
            }
        }
        
    }
    
    private func createDailyTopic(_ topic: TopicDaily? = nil) async {
        
        do {
            try await dailyTopicViewModel.manageRun(selectedAssistant: .topicDaily, topic: topic)
        } catch {
            await MainActor.run {
                dailyTopicViewModel.createTopic = .retry
            }
        }
        
        await createTopicQuestions(dailyTopicViewModel.currentTopic)
 
    }
    
    private func createTopicQuestions(_ topic: TopicDaily?) async {
        do {
            try await dailyTopicViewModel.manageRun(selectedAssistant: .topicDailyQuestions, topic: topic)
        } catch {
            await MainActor.run {
                dailyTopicViewModel.createTopicQuestions = .retry
            }
        }
    }
    
}
