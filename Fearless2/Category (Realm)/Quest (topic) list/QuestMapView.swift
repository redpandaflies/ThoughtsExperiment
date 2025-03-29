//
//  QuestMapView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 3/24/25.
//
import CoreData
import SwiftUI

struct QuestMapView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    
    @State private var showCreateNewTopicView: Bool = false
    @State private var playHapticEffect: Int = 0
    
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
                QuestMapCircle(topic: topic, backgroundColor: backgroundColor)
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
                    currentTabBar = .topic
                }
            }
        }
        .navigationDestination(isPresented: $navigateToTopicDetailView) {
            if let topic = selectedTopic {
                TopicDetailView(topicViewModel: topicViewModel, transcriptionViewModel: transcriptionViewModel, selectedTabTopic: $selectedTabTopic, topic: topic, points: points, totalCategories: totalCategories)
                    .toolbarRole(.editor) //removes the word "back" in the back button
                    
            }
        }
        .sheet(isPresented: $showCreateNewTopicView, onDismiss: {
            showCreateNewTopicView = false
        }) {
            NewTopicView(topicViewModel: topicViewModel, selectedTopic: $selectedTopic, navigateToTopicDetailView: $navigateToTopicDetailView, currentTabBar: $currentTabBar, category: category)
                .presentationDetents([.fraction(0.65)])
                .presentationCornerRadius(30)
                .interactiveDismissDisabled()
            
        }
    
    }
    
    //MARK: manage where to go depending on quest type and status
    private func onQuestTap(topic: Topic) {
        //play haptic
        playHapticEffect += 1
        
        let questType = QuestTypeItem(rawValue: topic.topicQuestType) ?? .guided
        let questStatus = TopicStatusItem.init(rawValue: topic.topicStatus) ?? .locked
        
        switch questType {
            default:
            if questStatus == .locked {
                //get topic suggestions
                getTopicSuggestions(topic: topic)
            } else {
                //navigate to topic detail view
                goToTopicDetailView(topic: topic)
                
            }
        }
    }
    
    private func goToTopicDetailView(topic: Topic) {
        //set selected topic ID so that delete topic works
        selectedTopic = topic
        
        if let scrollPosition = categoriesScrollPosition {
            currentCategory = scrollPosition
        }
        navigateToTopicDetailView = true
        
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
}

struct QuestMapCircle: View {
    @ObservedObject var topic: Topic
    let backgroundColor: Color
    
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
                    getSFSymbol(size: 25)
                }
            default:
                getSFSymbol(size: getSFSymbolSize())
            }
          
        }
        .frame(width: questStatus == .active ? 80 : 60, height: questStatus == .active ? 80 : 60)
        .background(
            Circle()
                .stroke(getStrokeColor(), lineWidth: 0.5)
                .fill(getFillStyle())
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(questStatus == .completed ? .colorDodge : .normal)
                .padding(questStatus == .active ? 7 : 0)
                .background {
                    Circle()
                        .stroke(questStatus == .active ? .white.opacity(0.4) : .clear, lineWidth: 0.5)
                        .fill(Color.clear)
                }
        )
    }
    
    private func getSFSymbol(size: CGFloat) -> some View {
        
        ZStack {
                    
            // the darker inset image
            Image(systemName: questIcon)
                .font(.system(size: size, weight: .heavy))
                .foregroundStyle(
                    questStatus == .completed ? Color.white.opacity(0.9) : backgroundColor.opacity(0.2)
                )
            
            // black inner shadow
            if questStatus != .completed {
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
            .font(.system(size: 20))
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
            return AnyShapeStyle(
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
            return Color.white.opacity(0.9)
            
        }
    }
    
    private func getSFSymbolSize() -> CGFloat {
        switch questType {
            case .newCategory, .context:
                return 20
            default:
                return 25
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

