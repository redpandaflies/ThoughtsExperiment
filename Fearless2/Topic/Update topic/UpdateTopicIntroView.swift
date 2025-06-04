//
//  UpdateTopicIntroView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/23/25.
//

import SwiftUI

struct UpdateTopicIntroView: View {
    @ObservedObject var topicViewModel: TopicViewModel
   
    @State private var lastCompleteSectionIndex: Int? = nil
    @State private var nextTopicIndex: Int? = nil
    
    @Binding var selectedTabTopicsList: Int
    
    let topic: Topic
    let sequence: Sequence
    let questions: FetchedResults<Question>
    let getQuestions: () -> Void
    let updateQuestionVariables: (Int) -> Void
    
    var topics: [Topic] {
        return sequence.sequenceTopics.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var topicsComplete: Int {
        return topics.filter { $0.status == TopicStatusItem.completed.rawValue }.count
    }
    
    let frameWidth: CGFloat = 310
    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    
    
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
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                case 1:
                    topicsList()
                        .padding(.horizontal)
                        .onAppear {
                            startAnimating()
                        }
                default:
                    FocusAreaRetryView(action: {
                        getQuestions()
                    })
                        .frame(width: frameWidth)
                        .padding(.top, 20)
                
            }
            
        }//VStack
        .onAppear {
            if topic.topicQuestions.isEmpty && topicViewModel.createTopicQuestions == .ready {
                // ensures that API has been made and there are questions for this topic
                getQuestions()
                
            } else {
                switch topicViewModel.createTopicQuestions {
                case .ready:
                    updateQuestionVariables(topic.topicQuestions.count)
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
                
                getContent(
                    index: index,
                    title: topics[index].topicTitle,
                    subtitle: (nextTopicIndex == index) ? topics[index].topicDefinition : ""
                )
                
            }//ForEach
        }
    }
    
    private func getContent(index: Int, title: String, subtitle: String) -> some View {
        
        HStack (alignment: .firstTextBaseline, spacing: 15) {
            
            if lastCompleteSectionIndex == index {
                Image(systemName: getIcon(index: index))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19))
                    .foregroundStyle(getColor(index: index))
                    .transition(
                        .movingParts.pop(AppColors.textPrimary)
                    )
            } else {
                Image(systemName: getIcon(index: index))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19))
                    .foregroundStyle(getColor(index: index))
                    .contentTransition(.symbolEffect(.replace.offUp.byLayer))
            }
               
            
            VStack (alignment: .leading, spacing: 5) {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19, design: .serif))
                    .foregroundStyle(getColor(index: index))
                    .fixedSize(horizontal: false, vertical: true)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 17, weight: .light))
                        .foregroundStyle(getColor(index: index))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            
        }//HStack
        
    }
    
    private func getIcon(index: Int) -> String {
        
        if index < topicsComplete - 1 {
            return "checkmark"
        } else if lastCompleteSectionIndex == index {
            return "checkmark"
        } else if nextTopicIndex == index {
            return "arrow.forward"
        } else if index == topicsComplete - 1 {
            return "arrow.forward"
        }
        
        return "lock.fill"
        
        
    }
    
    private func getColor(index: Int) -> Color {
        if index < topicsComplete - 1 {
            return AppColors.textPrimary.opacity(0.5)
        } else if lastCompleteSectionIndex == index {
            return AppColors.textPrimary.opacity(0.5)
        } else if nextTopicIndex == index {
            return AppColors.textPrimary
        } else if index == topicsComplete - 1 {
            return AppColors.textPrimary.opacity(0.5)
        }
        
        return AppColors.textPrimary.opacity(0.2)
    }
    
    private func startAnimating() {
        
        // reset state vars
        lastCompleteSectionIndex = nil
        nextTopicIndex = nil
        
        print("Topics complete: \(topicsComplete)")
        hapticImpact.prepare()
        
        // start animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.snappy(duration: 0.7)) {
                let currentIndex = topicsComplete - 1
                hapticImpact.impactOccurred(intensity: 0.5)
                lastCompleteSectionIndex = currentIndex
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.smooth(duration: 0.2)) {
                    let nextIndex = topicsComplete
                    hapticImpact.impactOccurred(intensity: 0.7)
                    nextTopicIndex = nextIndex
                }
            }
        }
       
    }

}

