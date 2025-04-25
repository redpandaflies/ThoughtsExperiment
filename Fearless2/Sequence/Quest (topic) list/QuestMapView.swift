//
//  QuestMapView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/24/25.
//
import CoreData
import Mixpanel
import Pow
import SwiftUI

struct QuestMapView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModelFactoryMain: ViewModelFactoryMain
    @ObservedObject var topicViewModel: TopicViewModel
    
    
    @State private var playHapticEffect: Int = 0
    @State private var showUpdateTopicView: Bool = false
    @State private var showLockedQuestInfoSheet: Bool = false
    @State private var showCompletedTopicSheet: Bool = false
    @State private var showTopicExpectationsSheet: Bool = false
    @State private var showNextSequenceView: Bool = false
    @State private var sequenceScrollPosition: Int?
    @State private var currentSequenceIndex: Int = 0 // to manage which sequence is being displayed
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    
    let category: Category
    let points: Int
    let backgroundColor: Color
    let goal: Goal

    @FetchRequest var sequences: FetchedResults<Sequence>
    
    @AppStorage("currentAppView") var currentAppView: Int = 0
    @AppStorage("selectedTopicId") var selectedTopicId: String = ""
    
   
    var totalCompletedTopics: Int {
        guard sequences.indices.contains(currentSequenceIndex) else {
            return 0
        }
        let sequence = sequences[currentSequenceIndex]
        
        let relatedTopics = sequence.sequenceTopics
        
        let completedTopics = relatedTopics.filter { $0.topicStatus == TopicStatusItem.completed.rawValue }
        
        return completedTopics.count
    }
    
    let screenWidth = UIScreen.current.bounds.width
    
    var frameWidth: CGFloat {
        return screenWidth - 96
    }
    
    init(topicViewModel: TopicViewModel,
         selectedTopic: Binding<Topic?>,
         currentTabBar: Binding<TabBarType>,
         selectedTabTopic: Binding<TopicPickerItem>,
         category: Category,
         points: Int,
         backgroundColor: Color,
         goal: Goal
    ) {
        
        self.topicViewModel = topicViewModel
        self._selectedTopic = selectedTopic
        self._currentTabBar = currentTabBar
        self._selectedTabTopic = selectedTabTopic
        self.category = category
        self.points = points
        self.backgroundColor = backgroundColor
        self.goal = goal
        
        let request: NSFetchRequest<Sequence> = Sequence.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.predicate = NSPredicate(format: "goal == %@", goal)
        self._sequences = FetchRequest(fetchRequest: request)
        
    }
    
    
    var body: some View {
        VStack (spacing: 15) {

                getBoxHeader(goalType: goal.goalProblemType)
                    .padding(.bottom, 10)
                
                Text(goal.goalTitle)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20, weight: .medium, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(goal.goalProblem)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(AppColors.textPrimary.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(1.4)
                
                //            GoalProgressBar(totalTopics: topics.count, totalCompletedTopics: totalCompletedTopics, wholeBarWidth: frameWidth + 32)
                //                .padding(.vertical)
                
                // show only the latest sequence
                if let firstSequence = sequences.first {
                    QuestGridView(
                        // sheet‐presentation bindings
                        showUpdateTopicView: $showUpdateTopicView,
                        showLockedQuestInfoSheet: $showLockedQuestInfoSheet,
                        showCompletedTopicSheet: $showCompletedTopicSheet,
                        showTopicExpectationsSheet: $showTopicExpectationsSheet,
                        showNextSequenceView: $showNextSequenceView,
                        
                        // navigation bindings
                        selectedTopic: $selectedTopic,
                        currentTabBar: $currentTabBar,
                        selectedTabTopic: $selectedTabTopic,
                        
                        sequence: firstSequence,
                        backgroundColor: backgroundColor,
                        frameWidth: frameWidth
                    )
                }
           
        }//VStack
        .padding(.horizontal)
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(AppColors.whiteDefault.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.boxGrey6.opacity(0.3))
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(.colorDodge)
        }
        .frame(width: (screenWidth - 32), height: 407)
        .onAppear {
            withAnimation(.snappy(duration: 0.2)) {
                currentTabBar = .home
            }
            if playHapticEffect != 0 {
                playHapticEffect = 0
            }
        
        }
        .fullScreenCover(isPresented: $showUpdateTopicView, onDismiss: {
            showUpdateTopicView = false
        }) {
            //create new topic/quest
            if let topic = selectedTopic, let sequence = sequences.first {
                UpdateTopicView(
                    topicViewModel: topicViewModel,
                    showUpdateTopicView: $showUpdateTopicView,
                    topic: topic,
                    sequence: sequence,
                    backgroundColor: backgroundColor
                )
            }
        }
        .sheet(isPresented: $showLockedQuestInfoSheet, onDismiss: {
            showLockedQuestInfoSheet = false
        }) {
            // locked new topic/quest
            InfoPrimaryView(
                backgroundColor: backgroundColor,
                useIcon: true,
                iconName: "questionmark",
                iconWeight: .heavy,
                titleText: "What lies ahead?",
                descriptionText: "Only one way to know — keep exploring.",
                useRectangleButton: false,
                buttonAction: {
                    dismiss()
                })
            .presentationDetents([.fraction(0.65)])
            .presentationCornerRadius(30)
        }
        .sheet(isPresented: $showCompletedTopicSheet, onDismiss: {
            showCompletedTopicSheet = false
        }) {
            // completed topics/quests
            if let topic = selectedTopic {
                CompletedTopicSheetView(topic: topic, backgroundColor: backgroundColor)
                    .presentationDetents([.fraction(0.95)])
                    .presentationCornerRadius(30)
            }
        }
        .fullScreenCover(isPresented: $showTopicExpectationsSheet, onDismiss: {
            showTopicExpectationsSheet = false
        }) {
            
            TopicExpectationsView(
                topicViewModel: topicViewModel,
                showTopicExpectationsSheet: $showTopicExpectationsSheet,
                topic: selectedTopic,
                goal: goal.goalTitle,
                sequence: sequences.first,
                expectations: selectedTopic?.topicExpectations ?? [],
                backgroundColor: backgroundColor)
        }
        .fullScreenCover(isPresented: $showNextSequenceView, onDismiss: {
            showNextSequenceView = false
        }) {
            
            NextSequenceView(
                sequenceViewModel: viewModelFactoryMain.makeSequenceViewModel(),
                newCategoryViewModel: viewModelFactoryMain.makeNewCategoryViewModel(),
                goal: goal,
                sequence: sequences[currentSequenceIndex],
                topic: selectedTopic,
                backgroundColor: backgroundColor,
                showNextSequenceView: $showNextSequenceView)
        }
    }
    
    private func getBoxHeader(goalType: String) -> some View {
        
        HStack {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 23, weight: .light).smallCaps())
                .opacity(0)
            
            Spacer()
            
            Text(goalType)
                .font(.system(size: 15, weight: .light).smallCaps())
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
            
            Spacer()
            
            Button {
                
                
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 23, weight: .light).smallCaps())
                    .foregroundStyle(AppColors.textPrimary.opacity(0.7))
            }
            
            
        }
    }
    
}



extension View {
    // https://www.raywenderlich.com/7589178-how-to-create-a-neumorphic-design-with-swiftui
    func inverseMask<Mask>(_ mask: Mask) -> some View where Mask: View {
        self.mask(mask
            .foregroundColor(.black)
            .background(Color.white)
            .compositingGroup()
            .luminanceToAlpha()
        )
    }
}

