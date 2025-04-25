//
//  QuestGridView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/23/25.
//
import CoreData
import SwiftUI

struct QuestGridView: View {
    @State private var playHapticEffect: Int = 0
    
    // sheets
    @Binding var showUpdateTopicView: Bool
    @Binding var showLockedQuestInfoSheet: Bool
    @Binding var showCompletedTopicSheet: Bool
    @Binding var showTopicExpectationsSheet: Bool
    @Binding var showNextSequenceView: Bool

    // navigation
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    
    let sequence: Sequence
    let backgroundColor: Color
    let frameWidth: CGFloat
    
    let columns = [
        GridItem(.fixed(88), spacing: 0),
        GridItem(.fixed(88), spacing: 0),
        GridItem(.fixed(88), spacing: 0),
        GridItem(.fixed(88), spacing: 0)
    ]
    
    @FetchRequest var topics: FetchedResults<Topic>
    
    private var nextQuest: Int {
       let activeCount = topics.filter { $0.topicStatus == TopicStatusItem.active.rawValue }.count
       let nextIndex = topics.first(where: { $0.topicStatus == TopicStatusItem.locked.rawValue })?.orderIndex ?? -1
       return activeCount == 0 ? Int(nextIndex) : -1
     }
    
    init(
    showUpdateTopicView: Binding<Bool>,
       showLockedQuestInfoSheet: Binding<Bool>,
       showCompletedTopicSheet: Binding<Bool>,
       showTopicExpectationsSheet: Binding<Bool>,
       showNextSequenceView: Binding<Bool>,
        
       selectedTopic: Binding<Topic?>,
       currentTabBar: Binding<TabBarType>,
       selectedTabTopic: Binding<TopicPickerItem>,
       
      sequence: Sequence,
      backgroundColor: Color,
      frameWidth: CGFloat
      
    ) {
        self._showUpdateTopicView = showUpdateTopicView
       self._showLockedQuestInfoSheet = showLockedQuestInfoSheet
       self._showCompletedTopicSheet = showCompletedTopicSheet
       self._showTopicExpectationsSheet = showTopicExpectationsSheet
       self._showNextSequenceView = showNextSequenceView

       self._selectedTopic = selectedTopic
       self._currentTabBar = currentTabBar
       self._selectedTabTopic = selectedTabTopic

      self.sequence = sequence
      self.backgroundColor = backgroundColor
      self.frameWidth = frameWidth
 

      // Build a fetch request for all Topics belonging to this sequence
      let request: NSFetchRequest<Topic> = Topic.fetchRequest()
      request.sortDescriptors = [
        NSSortDescriptor(key: "orderIndex", ascending: true)
      ]
      request.predicate = NSPredicate(format: "sequence == %@", sequence)
      self._topics = FetchRequest(fetchRequest: request)
    }
    
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 25) {
            if !topics.isEmpty {
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
        }//VGrid
        .frame(width: frameWidth)
    }
    
    private func onQuestTap(topic: Topic) {
        //play haptic
        playHapticEffect += 1
        
        let questType = QuestTypeItem(rawValue: topic.topicQuestType) ?? .guided
        let questStatus = TopicStatusItem.init(rawValue: topic.topicStatus) ?? .locked
        
        if questType == .guided || questType == .context {
            switch questStatus {

            case .locked:
                if nextQuest == topic.orderIndex {
                    // start create topic flow
                    getTopic(topic: topic)
                } else {
                    // show sheet for locked quests
                     showLockedQuestInfoSheet = true
                }
                
            default:
//                //set selected topic to current topic
                selectedTopic = topic
                
//                //open sheet
                showCompletedTopicSheet = true
                
                //navigate to topic detail view (for testing)
//                goToTopicDetailView(topic: topic)
            }
            
        } else if questType == .expectations {
            //set selected topic to current topic
            selectedTopic = topic
            //open sheet for discovering new category/realm
            showTopicExpectationsSheet = true
             
        } else if questType == .retro {
            selectedTopic = topic
            
            showNextSequenceView = true
        }
        
    }
    
    private func getTopic(topic: Topic) {
        //set selected topic ID so that delete topic works
        selectedTopic = topic
        
        showUpdateTopicView = true
    }
}
