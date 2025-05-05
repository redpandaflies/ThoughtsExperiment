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
    @Binding var showTopicBreakView: Bool
    @Binding var showNextSequenceView: Bool

    // navigation
    @Binding var selectedTopic: Topic?
    @Binding var currentTabBar: TabBarType
    @Binding var selectedTabTopic: TopicPickerItem
    
    let sequence: Sequence?
    let backgroundColor: Color
    let frameWidth: CGFloat
    
    let columns = [
        GridItem(.fixed(80), spacing: 0),
        GridItem(.fixed(80), spacing: 0),
        GridItem(.fixed(80), spacing: 0),
        GridItem(.fixed(80), spacing: 0)
    ]
    
    @FetchRequest var topics: FetchedResults<Topic>
    
    private var nextQuest: Int {
       let nextIndex = topics.first(where: { $0.topicStatus == TopicStatusItem.locked.rawValue })?.orderIndex ?? -1
       return Int(nextIndex)
     }
    
    init(
       showUpdateTopicView: Binding<Bool>,
       showLockedQuestInfoSheet: Binding<Bool>,
       showCompletedTopicSheet: Binding<Bool>,
       showTopicExpectationsSheet: Binding<Bool>,
       showTopicBreakView: Binding<Bool>,
       showNextSequenceView: Binding<Bool>,
        
       selectedTopic: Binding<Topic?>,
       currentTabBar: Binding<TabBarType>,
       selectedTabTopic: Binding<TopicPickerItem>,
       
      sequence: Sequence?,
      backgroundColor: Color,
      frameWidth: CGFloat
      
    ) {
       self._showUpdateTopicView = showUpdateTopicView
       self._showLockedQuestInfoSheet = showLockedQuestInfoSheet
       self._showCompletedTopicSheet = showCompletedTopicSheet
       self._showTopicExpectationsSheet = showTopicExpectationsSheet
       self._showTopicBreakView = showTopicBreakView
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
        if let sequence = sequence {
            request.predicate = NSPredicate(format: "sequence == %@", sequence)
        }
      self._topics = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
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
        // Play haptic
        playHapticEffect += 1

        let questType = QuestTypeItem(rawValue: topic.topicQuestType) ?? .guided

        switch questType {
       
            
        case .expectations:
            selectedTopic = topic
            showTopicExpectationsSheet = true
        
        case .break1:
            break1Action(for: topic)
            
        case .retro:
            selectedTopic = topic
            showNextSequenceView = true
            
        default:
            handleDefaultQuestTap(for: topic)
        }
    }

    private func handleDefaultQuestTap(for topic: Topic) {
        let questStatus = TopicStatusItem(rawValue: topic.topicStatus) ?? .locked

        switch questStatus {
        case .locked:
            if nextQuest == topic.orderIndex {
                getTopicDefault(topic: topic) // start create topic flow
            } else {
                showLockedQuestInfoSheet = true
            }

        default:
            selectedTopic = topic
            showCompletedTopicSheet = true
        }
    }
    
    private func break1Action(for topic: Topic) {
        let questStatus = TopicStatusItem(rawValue: topic.topicStatus) ?? .locked
        
        switch questStatus {
       
            case .locked:
                if nextQuest == topic.orderIndex {
                    getTopicBreak(topic: topic) // start create topic flow
                } else {
                    showLockedQuestInfoSheet = true
                }
                
            default:
               selectedTopic = topic
            
        }
        
        
    }
    
    private func getTopicDefault(topic: Topic) {
        //set selected topic ID so that delete topic works
        selectedTopic = topic
        
        showUpdateTopicView = true
    }
    
    private func getTopicBreak(topic: Topic) {
        //set selected topic ID so that delete topic works
        selectedTopic = topic
        
        showTopicBreakView = true
    }
}
