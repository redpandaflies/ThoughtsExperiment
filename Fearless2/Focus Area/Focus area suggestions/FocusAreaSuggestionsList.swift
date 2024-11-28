//
//  FocusAreaSuggestionsList.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/27/24.
//

import SwiftUI

struct FocusAreaSuggestionsList: View {
    
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    let suggestions: [any SuggestionProtocol]
    private let screenWidth = UIScreen.current.bounds.width
    
    let action: () -> Void
    let topic: Topic?
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack (alignment: .top, spacing: 15) {
                ForEach(suggestions, id: \.title) { suggestion in
                    FocusAreaSuggestionBox(suggestion: suggestion)
                        .frame(width: screenWidth * 0.85)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0.5)
                                .scaleEffect(y: phase.isIdentity ? 1 : 0.85)
                        }
                        .onTapGesture {
                           action()
                            createFocusArea(suggestion: suggestion, topic: topic)
                        }
                }
            }//Hstack
            .scrollTargetLayout()
            
        }//Scrollview
        .scrollClipDisabled(true)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, (screenWidth * 0.15)/2, for: .scrollContent)
    }
    
    private func createFocusArea(suggestion: any SuggestionProtocol, topic: Topic?) {
    
        Task {
            //save the suggestion as focus area
            guard let focusArea = await dataController.createFocusArea(suggestion: suggestion, topic: topic) else {
                return
            }
            
            //API call to create new focus area
            await topicViewModel.manageRun(selectedAssistant: .focusArea, topicId: topic?.topicId, focusArea: focusArea)
        }
    }
}

struct FocusAreaSuggestionBox: View {
   
    let suggestion: any SuggestionProtocol
    
    var body: some View {
        VStack (spacing: 20) {
            
            Text(suggestion.symbol)
                .font(.system(size: 35))

            Text(suggestion.title)
                .font(.system(size: 17))
                .foregroundStyle(Color.white)
            
            WhyBox(text: suggestion.suggestionDescription, backgroundColor: AppColors.black1)
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 30))
                .foregroundStyle(Color.white)
        }
        .padding()
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1))
                .fill(AppColors.black3)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        }
        
    }
}

