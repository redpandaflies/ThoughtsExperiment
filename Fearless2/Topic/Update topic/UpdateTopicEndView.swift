//
//  UpdateTopicEndView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/23/25.
//

import SwiftUI

struct UpdateTopicEndView: View {
    @ObservedObject var topicViewModel: TopicViewModel
   
    @State private var lastCompleteSectionIndex: Int? = nil
    @State private var nextTopicIndex: Int? = nil
    
    @Binding var selectedTabTopicsList: Int
    
    let sequence: Sequence
    let questions: FetchedResults<Question>
    
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
          
            topicsList()
                .padding(.horizontal)
            
        }//VStack
        .onAppear {
            startAnimating()
        }
    }
    
    private func topicsList() -> some View {
        VStack (alignment: .leading, spacing: 25) {
            ForEach(topics.indices, id: \.self) { index in
                
                getContent(
                    index: index,
                    title: topics[index].topicTitle
                )
                
            }//ForEach
        }
    }
    
    private func getContent(index: Int, title: String) -> some View {
        
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
            
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19, design: .serif))
                .foregroundStyle(getColor(index: index))
            
            
            
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
            return AppColors.textPrimary
        } else if nextTopicIndex == index {
            return AppColors.textPrimary.opacity(0.5)
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

