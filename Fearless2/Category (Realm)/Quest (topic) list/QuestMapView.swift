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
   
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    
    @State private var showCreateNewTopicView: Bool = false
    @State private var playHapticEffect: Int = 0
    @State private var showLockedQuestInfoSheet: Bool = false
    @State private var showCompletedTopicSheet: Bool = false
    @State private var showCreateNewCategory: Bool = false
    @State private var showLockedNewCategory: Bool = false
    @State private var showDiscoveredNewCategory: Bool = false
    
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var navigateToTopicDetailView: Bool
    @Binding var categoriesScrollPosition: Int?
    
    @ObservedObject var category: Category
    @ObservedObject var points: Points
    let totalCategories: Int
    let backgroundColor: Color
    
    let columns = [
        GridItem(.fixed(88), spacing: 0),
        GridItem(.fixed(88), spacing: 0),
        GridItem(.fixed(88), spacing: 0),
        GridItem(.fixed(88), spacing: 0)
    ]
    
    @FetchRequest var topics: FetchedResults<Topic>
    
    @AppStorage("currentCategory") var currentCategory: Int = 0
    @AppStorage("currentAppView") var currentAppView: Int = 0
    @AppStorage("selectedTopicId") var selectedTopicId: String = ""
    
    //to account for the scenario where the quest is next, but is still locked (user hasn't picked a new quest)
    var nextQuest: Int {
        let activeTopics = topics.filter { $0.topicStatus == TopicStatusItem.active.rawValue }.count
        let nextTopic = topics.first(where: { $0.topicStatus == TopicStatusItem.locked.rawValue })?.orderIndex ?? -1
        return activeTopics == 0 ? Int(nextTopic) : -1
        
    }
    
    init(topicViewModel: TopicViewModel,
         transcriptionViewModel: TranscriptionViewModel,
         selectedTopic: Binding<Topic?>,
         currentTabBar: Binding<TabBarType>,
         selectedTabTopic: Binding<TopicPickerItem>,
         navigateToTopicDetailView: Binding<Bool>,
         categoriesScrollPosition: Binding<Int?>,
         category: Category,
         points: Points,
         totalCategories: Int,
         backgroundColor: Color
    ) {
        
        self.topicViewModel = topicViewModel
        self.transcriptionViewModel = transcriptionViewModel
        self._selectedTopic = selectedTopic
        self._currentTabBar = currentTabBar
        self._selectedTabTopic = selectedTabTopic
        self._navigateToTopicDetailView = navigateToTopicDetailView
        self._categoriesScrollPosition = categoriesScrollPosition
        self.category = category
        self.points = points
        self.totalCategories = totalCategories
        self.backgroundColor = backgroundColor
        
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "status != %@", TopicStatusItem.archived.rawValue),
            NSPredicate(format: "category == %@", category)
        ])
        self._topics = FetchRequest(fetchRequest: request)
        
    }
    
    
    var body: some View {
  
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(Array(topics), id: \.topicId) { topic in
                    QuestMapCircle(
                        topic: topic,
                        backgroundColor: backgroundColor,
                        nextQuest: nextQuest == topic.orderIndex
                    )
                    .onTapGesture {
                        onQuestTap(topic: topic)
                    }
                    .sensoryFeedback(.selection, trigger: playHapticEffect)
                    
                   
                }
                
                
            }
            .onAppear {
                withAnimation(.snappy(duration: 0.2)) {
                    currentTabBar = .home
                }
                if playHapticEffect != 0 {
                    playHapticEffect = 0
                }
               
            }
            .onDisappear {
                if navigateToTopicDetailView {
                    
                    withAnimation(.snappy(duration: 0.2)) {
                        if currentTabBar != .topic {
                            currentTabBar = .topic
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToTopicDetailView) {
                if let topic = selectedTopic {
                    TopicDetailView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, points: points, selectedTabTopic: $selectedTabTopic, topic: topic, totalCategories: totalCategories)
                        .toolbarRole(.editor) //removes the word "back" in the back button
                }
            }
           
            .sheet(isPresented: $showCreateNewTopicView, onDismiss: {
                showCreateNewTopicView = false
            }) {
                //create new topic/quest
                NewTopicView(topicViewModel: topicViewModel, selectedTopic: $selectedTopic, navigateToTopicDetailView: $navigateToTopicDetailView, currentTabBar: $currentTabBar, category: category)
                    .presentationDetents([.fraction(0.95)])
                    .presentationCornerRadius(30)
                    .interactiveDismissDisabled()
                
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
            .sheet(isPresented: $showCreateNewCategory, onDismiss: {
                showCreateNewCategory = false
            }) {
                // unlock new category/realm
                InfoPrimaryView(
                    backgroundColor: backgroundColor,
                    useIcon: true,
                    iconName: "mountain.2.fill",
                    titleText: "A new realm emerges",
                    descriptionText: "The path ahead is shifting.\nStep forward and see where it leads.",
                    useRectangleButton: true,
                    rectangleButtonText: "Unveil your next realm",
                    buttonAction: {
                        if let topic = selectedTopic {
                            startNewRealmFlow(topic: topic)
                        }
                    })
                .presentationDetents([.fraction(0.65)])
                .presentationCornerRadius(30)
            }
            .sheet(isPresented: $showLockedNewCategory, onDismiss: {
                showLockedNewCategory = false
            }) {
                // new category discovery, locked
                InfoPrimaryView(
                    backgroundColor: backgroundColor,
                    useIcon: true,
                    iconName: "mountain.2.fill",
                    iconWeight: .heavy,
                    titleText: "Undiscovered realm",
                    descriptionText: "You haven’t found this realm yet, but your\njourney is leading you there.",
                    useRectangleButton: false,
                    buttonAction: {
                        dismiss()
                    })
                .presentationDetents([.fraction(0.65)])
                .presentationCornerRadius(30)
            }
            .sheet(isPresented: $showDiscoveredNewCategory, onDismiss: {
                showDiscoveredNewCategory = false
            }) {
                // after discovering new category/realm
                InfoPrimaryView(
                    backgroundColor: backgroundColor,
                    useIcon: true,
                    iconName: "mountain.2.fill",
                    iconWeight: .heavy,
                    titleText: "You've discovered a new realm",
                    descriptionText: "Venture further to reveal what’s next.",
                    useRectangleButton: false,
                    buttonAction: {
                        dismiss()
                    })
                .presentationDetents([.fraction(0.65)])
                .presentationCornerRadius(30)
            }
        
    
    }
    
    //MARK: manage where to go depending on quest type and status
    private func onQuestTap(topic: Topic) {
        //play haptic
        playHapticEffect += 1
        
        let questType = QuestTypeItem(rawValue: topic.topicQuestType) ?? .guided
        let questStatus = TopicStatusItem.init(rawValue: topic.topicStatus) ?? .locked
        
        if questType == .guided {
            switch questStatus {
            case .active, .archived:
                //navigate to topic detail view
                goToTopicDetailView(topic: topic)
                
            case .locked:
                if nextQuest == topic.orderIndex {
                    //get topic suggestions
                    getTopicSuggestions(topic: topic)
                } else {
                    // show sheet for locked quests
                     showLockedQuestInfoSheet = true
                }
                
            case .completed:
                //set selected topic to current topic
                selectedTopic = topic
                
                //open sheet
                showCompletedTopicSheet = true
            }
            
        } else if questType == .newCategory {
            switch questStatus {
                
                case .locked:
                    if nextQuest == topic.orderIndex {
                        //set selected topic to current topic
                        selectedTopic = topic
                        //open sheet for discovering new category/realm
                        showCreateNewCategory = true
                    } else {
                        //show sheet for locked quests
                        showLockedNewCategory = true
                    }
                    
                case .completed:
                    //open sheet
                    showDiscoveredNewCategory = true
                    
                default:
                    break
                
            }
        }
        
    }
    
    private func goToTopicDetailView(topic: Topic) {
        //set selected topic ID so that delete topic works
        selectedTopic = topic
        print("selectedTopic set to \(selectedTopic?.topicTitle ?? "none")")
        
        if let scrollPosition = categoriesScrollPosition {
            currentCategory = scrollPosition
        }
        
        if selectedTopic == topic {
            print("moving to topic detail view 1")
            navigateToTopicDetailView = true
        } else {
            selectedTopic = topic
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("moving to topic detail view 2")
                navigateToTopicDetailView = true
            }
        }
        
        //change footer
        withAnimation(.snappy(duration: 0.2)) {
            currentTabBar = .topic
        }
    }
    
    private func getTopicSuggestions(topic: Topic) {
        //set selected topic ID so that delete topic works
        selectedTopic = topic
        
        if let scrollPosition = categoriesScrollPosition {
            currentCategory = scrollPosition
        }
        showCreateNewTopicView = true
    }
    
    private func startNewRealmFlow(topic: Topic) {
       
        currentAppView = 2
        
        selectedTopicId = topic.topicId.uuidString
        
        DispatchQueue.global(qos: .background).async {
            Mixpanel.mainInstance().track(event: "Started unveiling a new realm")
        }
    }
}

struct QuestMapCircle: View {
    @ObservedObject var topic: Topic
    
    @State private var playAnimation: Bool = false
//    @State private var timer: Timer? = nil
    
    let backgroundColor: Color
    let nextQuest: Bool //quest that is next but yet active (user has not picked the quest yet)
    
    private var questType: QuestTypeItem {
       return QuestTypeItem(rawValue: topic.topicQuestType) ?? .guided
    }
    
    private var questStatus: TopicStatusItem {
        return TopicStatusItem.init(rawValue: topic.topicStatus) ?? .locked
    }
    
    private var questIcon: String {
       return questType.getIconName()
    }
    
    var body: some View {
        Group {
            
            switch questType {
            case .guided:
                if questStatus == .active || questStatus == .completed {
                    getEmoji()
                } else {
                    getSFSymbol(size: nextQuest ? 30 : 25)
                }
            default:
                getSFSymbol(size: getSFSymbolSize())
            }
          
        }
        .frame(width: questStatus == .active || nextQuest ? 80 : 60, height: questStatus == .active || nextQuest ? 80 : 60)
        .background(
            Circle()
                .stroke(getStrokeColor(), lineWidth: 0.5)
                .fill(getFillStyle())
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(questStatus == .completed ? .colorDodge : .normal)
                .padding(questStatus == .active || nextQuest ? 7 : 0)
                .background {
                    Circle()
                        .stroke(questStatus == .active || nextQuest ? .white.opacity(0.4) : .clear, lineWidth: 0.5)
                        .fill(Color.clear)
                }
        )
        .conditionalEffect(
              .repeat(
                .glow(color: AppColors.boxYellow1, radius: 70),
                every: 4
              ),
              condition: playAnimation
          )
        .onAppear {
            if questStatus == .active || nextQuest {
                playAnimation = true
            }
        }
        .onDisappear {
            playAnimation = false
        }
    }
    
    private func getSFSymbol(size: CGFloat) -> some View {
        
        ZStack {
                    
            // the darker inset image
            Image(systemName: questIcon)
                .font(.system(size: size, weight: .heavy))
                .foregroundStyle(
                    questStatus == .locked && !nextQuest ?  backgroundColor.opacity(0.2) : Color.white.opacity(0.9)
                )
                .shadow(color: questStatus == .locked && !nextQuest ? .clear : Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
           
            // black inner shadow
            if questStatus == .locked && !nextQuest {
                Rectangle()
                    .inverseMask(Image(systemName: questIcon).font(.system(size: size, weight: .heavy)))
                    .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
                    .mask(Image(systemName: questIcon).font(.system(size: size, weight: .heavy)))
                    .clipped()
            }
            
        }
    }
    
    private func getEmoji() -> some View {
        Text(topic.topicEmoji)
            .font(.system(size: questStatus == .active || nextQuest ? 30 : 20))
    }
    
    private func getFillStyle() -> AnyShapeStyle {
        switch questStatus {
        case .completed:
            return AnyShapeStyle(
                AppColors.boxGrey1.opacity(0.3)
            )
        case .active:
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.boxYellow1, AppColors.boxYellow2]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        default:
            return nextQuest ? AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.boxYellow1, AppColors.boxYellow2]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            ) : AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [.white, AppColors.boxPrimary]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    private func getStrokeColor() -> Color {
        switch questStatus {
        case .completed:
           return Color.white.opacity(0.1)
          
        case .active:
            return Color.white
        default:
            return nextQuest ? Color.white : Color.white.opacity(0.9)
            
        }
    }
    
    private func getSFSymbolSize() -> CGFloat {
        switch questType {
            case .newCategory, .context:
                return questStatus == .active || nextQuest ? 25: 20
            default:
            return questStatus == .active || nextQuest ? 30 : 25
        }
    }
    
//    private func startTimer() {
//            // Cancel any existing timer
//            stopTimer()
//            
//            // Create a new timer that fires every 3 seconds
//            timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
//                // Update the animation count on the main thread
//                DispatchQueue.main.async {
//                    animationCount += 1
//                }
//            }
//        }
//        
//    private func stopTimer() {
//        timer?.invalidate()
//        timer = nil
//    }
  
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

