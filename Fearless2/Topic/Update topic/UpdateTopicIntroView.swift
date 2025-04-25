//
//  UpdateTopicIntroView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/23/25.
//

import SwiftUI

struct UpdateTopicIntroView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTabTopicsList: Int = 0
   
    let topic: Topic
    let sequence: Sequence
    
    var topics: [Topic] {
        return sequence.sequenceTopics.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var topicsComplete: Int {
        return topics.filter { $0.status == TopicStatusItem.completed.rawValue }.count
    }
    
    var nextTopicIndex: Int {
        return topicsComplete
    }
    
    let frameWidth: CGFloat = 310
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10){
            
            HStack {
                Text(sequence.sequenceTitle)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 25, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
            
            
            switch selectedTabTopicsList {
            case 0:
                LoadingPlaceholderContent(contentType: .newTopic)
                    .frame(width: frameWidth)
                    .padding(.top, 20)
            case 1:
                topicsList()
            default:
                FocusAreaRetryView(action: {
                    getTopicQuestions()
                })
                .frame(width: frameWidth)
                .padding(.top, 20)
                
            }
            
        }//VStack
        .onAppear {
            
            if topic.topicQuestions.isEmpty && topicViewModel.createTopicQuestions == .ready {
                // ensures that API has been made and there are questions for this topic
                getTopicQuestions()
            } else {
                switch topicViewModel.createTopicQuestions {
                case .ready:
                    selectedTabTopicsList = 1
                case .loading:
                    selectedTabTopicsList = 0
                case .retry:
                    selectedTabTopicsList = 2
                }
            }
            
        }
        .onChange(of: topicViewModel.createTopicQuestions) {
            switch topicViewModel.createTopicQuestions {
            case .ready:
                selectedTabTopicsList = 1
            case .loading:
                selectedTabTopicsList = 0
            case .retry:
                selectedTabTopicsList = 2
            }
        }
    }
    
    private func topicsList() -> some View {
        VStack (alignment: .leading, spacing: 25) {
            ForEach(topics.indices, id: \.self) { index in
                
                getContent(index: index, title: topics[index].topicTitle, subtitle: (nextTopicIndex == index) ? topics[index].topicDefinition : "")
                
            }//ForEach
        }
    }
    
    private func getContent(index: Int, title: String, subtitle: String) -> some View {
        
        HStack (alignment: .firstTextBaseline, spacing: 15) {
            
            Image(systemName: getIcon(index: index))
                .multilineTextAlignment(.leading)
                .font(.system(size: 19))
                .foregroundStyle(getColor(index: index))
               
            
            VStack (alignment: .leading, spacing: 5) {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19, design: .serif))
                    .foregroundStyle(getColor(index: index))
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 19, weight: .thin))
                        .fontWidth(.condensed)
                        .foregroundStyle(getColor(index: index))
                }
            }
            
            
        }//HStack
        
    }
    
    private func getIcon(index: Int) -> String {
        
        if index < topicsComplete {
            return "checkmark"
        } else if nextTopicIndex == index {
            return "arrow.forward"
        } else {
            return "lock.fill"
        }
        
    }
    
    private func getColor(index: Int) -> Color {
        if nextTopicIndex == index {
            return AppColors.textPrimary
        } else {
            return AppColors.textPrimary.opacity(0.5)
        }
    }
    
    private func getTopicQuestions() {
        topicViewModel.createTopicQuestions = .loading
        
        Task {
            do {
               
                try await topicViewModel.manageRun(selectedAssistant: .topic, topic: topic)
              
                
            } catch {
                topicViewModel.createTopicQuestions = .retry
            }
            
        }
    }
    
}

