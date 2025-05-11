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
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var playHapticEffect: Int = 0
    @State private var showUpdateTopicView: Bool = false
    @State private var showLockedQuestInfoSheet: Bool = false
    @State private var showCompletedTopicSheet: Bool = false
    @State private var showTopicExpectationsSheet: Bool = false
    @State private var showTopicBreakView: Bool = false
    @State private var showNextSequenceView: Bool = false
    
    @State private var sequenceScrollPosition: Int?
    @State private var currentSequenceIndex: Int = 0 // to manage which sequence is being displayed
    @State private var totalCompletedTopics: Int = 0
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var animatedGoalIDs: Set<UUID>
    
    @ObservedObject var goal: Goal
    let points: Int
    let backgroundColor: Color
    let frameWidth: CGFloat
    
    @FetchRequest var sequences: FetchedResults<Sequence>
    
    @AppStorage("currentAppView") var currentAppView: Int = 0
    @AppStorage("selectedTopicId") var selectedTopicId: String = ""
    
    private var currentSequence: Sequence? {
        sequences[currentSequenceIndex]
    }
    
    private var totalTopics: Int {
        currentSequence?.sequenceTopics.count ?? 0
    }
    
    
    init(topicViewModel: TopicViewModel,
         selectedTopic: Binding<Topic?>,
         currentTabBar: Binding<TabBarType>,
         selectedTabTopic: Binding<TopicPickerItem>,
         animatedGoalIDs: Binding<Set<UUID>>,
         goal: Goal,
         points: Int,
         backgroundColor: Color,
       
         frameWidth: CGFloat
    ) {
        
        self.topicViewModel = topicViewModel
        self._selectedTopic = selectedTopic
        self._currentTabBar = currentTabBar
        self._selectedTabTopic = selectedTabTopic
        self._animatedGoalIDs = animatedGoalIDs
        self.goal = goal
        self.points = points
        self.backgroundColor = backgroundColor
        self.frameWidth = frameWidth
        
        let request: NSFetchRequest<Sequence> = Sequence.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        request.predicate = NSPredicate(format: "goal == %@", goal)
        self._sequences = FetchRequest(fetchRequest: request)
        
    }
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15) {
            
            getBoxHeader(goalType: goal.goalProblemType)
                .padding(.bottom, 10)
                .padding(.horizontal)
            
            Text(goal.goalTitle)
                .multilineTextAlignment(.leading)
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            
            Text(goal.goalResolution)
                .multilineTextAlignment(.leading)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(AppColors.textPrimary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(1.4)
                .padding(.horizontal)
            
            // show only the latest sequence
            if !sequences.isEmpty {
                sequenceProgressBar()
                    .padding(.vertical)
                    .padding(.horizontal)
                
                QuestGridView(
                    // sheet‐presentation bindings
                    showUpdateTopicView: $showUpdateTopicView,
                    showLockedQuestInfoSheet: $showLockedQuestInfoSheet,
                    showCompletedTopicSheet: $showCompletedTopicSheet,
                    showTopicExpectationsSheet: $showTopicExpectationsSheet,
                    showTopicBreakView: $showTopicBreakView,
                    showNextSequenceView: $showNextSequenceView,
                    
                    // navigation bindings
                    selectedTopic: $selectedTopic,
                    currentTabBar: $currentTabBar,
                    selectedTabTopic: $selectedTabTopic,
                    
                    sequence: currentSequence ?? nil,
                    backgroundColor: backgroundColor,
                    frameWidth: frameWidth - 32
                )
                .frame(width: frameWidth, alignment: .center)
            }
            
            
        }//VStack
        .padding(.vertical, 20)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(AppColors.whiteDefault.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.boxGrey6.opacity(0.3))
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(.colorDodge)
        }
        .frame(width: frameWidth, height: 410)
        .onAppear {
            withAnimation(.snappy(duration: 0.2)) {
                currentTabBar = .home
            }
            if playHapticEffect != 0 {
                playHapticEffect = 0
            }
            currentSequenceIndex = sequences.count > 1 ? sequences.endIndex - 1 : 0
            
            updateSequenceProgressBar()
            
        }
        .onChange(of: topicViewModel.completedNewTopic) {
            if topicViewModel.completedNewTopic {
                updateSequenceProgressBar()
                topicViewModel.completedNewTopic = false
            }
        }
        .onChange(of: sequences.map(\.sequenceStatus)) { oldValue, newValue in
            if currentSequenceIndex != sequences.endIndex - 1 {
                currentSequenceIndex = sequences.endIndex - 1
            }
        }
        .fullScreenCover(isPresented: $showUpdateTopicView, onDismiss: {
            showUpdateTopicView = false
        }) {
            //create new topic/quest
            if let topic = selectedTopic, let sequence = currentSequence {
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
                sequence: currentSequence,
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
        .fullScreenCover(isPresented: $showTopicBreakView, onDismiss: {
            showTopicBreakView = false
        }) {
            if let topic = selectedTopic, let sequence = currentSequence {
                BreakView(
                    topicViewModel: topicViewModel,
                    showTopicBreakView: $showTopicBreakView,
                    topic: topic,
                    goal: goal.goalTitle,
                    sequence: sequence,
                    backgroundColor: backgroundColor)
            }
        }
    }
    
    private func getBoxHeader(goalType: String) -> some View {
        
        HStack {
            
            HStack (spacing: 3){
                Image(systemName: GoalTypeSymbol.symbolName(for: goalType, default: ""))
                    .font(.system(size: 15, weight: .light).smallCaps())
                    .fontWidth(.condensed)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                
                Text(goalType)
                    .font(.system(size: 15, weight: .light).smallCaps())
                    .fontWidth(.condensed)
                    .foregroundStyle(AppColors.textPrimary.opacity(0.7))
                
            }
            
            Spacer()
            
            Menu {
                if goal.goalSequences.count > 1 {
                    Menu {
                        
                        ForEach(Array(sequences.enumerated()), id: \.element.sequenceId) { index, sequence in
                            menuButton(text: sequence.sequenceTitle, index: index)
                        }
                    } label: {
                    
                        Label("Plans", systemImage: "checkmark")
                            .labelStyle(.titleOnly)
                            .font(.system(size: 14))
                    }
                }
                
                Button(role: .destructive) {
                    
                    Task {
                        await dataController.changeGoalStatus(goal: goal, newStatus: .abandoned)
                        
                        DispatchQueue.main.async {
                            self.animatedGoalIDs.remove(goal.goalId)
                        }
                    }
                    
                } label: {
                    // Your label view
                    Label("Delete", systemImage: "trash")
                }
                
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 23, weight: .light).smallCaps())
                    .foregroundStyle(AppColors.textPrimary.opacity(0.7))
            }
            
            
        }
    }
    
    private func menuButton(text: String, index: Int) -> some View {
        
        
            Button {
                if currentSequenceIndex != index {
                    currentSequenceIndex = index
                    updateSequenceProgressBar()
                }
            } label: {
                    Label("\(index + 1). \(text)", systemImage: currentSequenceIndex == index ? "checkmark" : "")
                        .font(.system(size: 14))
                
        }
        
    }
    
    private func sequenceProgressBar() -> some View {
        HStack (alignment: .center, spacing: 5) {
            Text("Part \(currentSequenceIndex + 1). \(currentSequence?.sequenceTitle ?? "")")
                .multilineTextAlignment(.leading)
                .font(.system(size: 15, weight: .light))
                .fontWidth(.condensed)
                .fixedSize(horizontal: true, vertical: true)
                .foregroundStyle(AppColors.textPrimary.opacity(0.7))
            
            ProgressBarThin(
                totalCompletedTopics: totalCompletedTopics,
                totalTopics: totalTopics
                )
                .frame(height: 15)
        }
        
    }
    
    private func updateSequenceProgressBar() {
        guard sequences.indices.contains(currentSequenceIndex) else {
            return
        }
        let sequence = sequences[currentSequenceIndex]
        
        let relatedTopics = sequence.sequenceTopics
        
        let completedTopics = relatedTopics.filter { $0.topicStatus == TopicStatusItem.completed.rawValue }
        
        withAnimation {
            totalCompletedTopics = completedTopics.count
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

