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
                    FocusAreaSuggestionBox(suggestion: suggestion, action: {
                        action()
                         createFocusArea(suggestion: suggestion, topic: topic)
                    })
                    .frame(width: screenWidth * 0.80)
                    .scrollTransition { content, phase in
                        content
                            .opacity(phase.isIdentity ? 1 : 0.7)
                            .scaleEffect(y: phase.isIdentity ? 1 : 0.85)
                    }
                }
            }//Hstack
            .scrollTargetLayout()
            
        }//Scrollview
        .scrollClipDisabled(true)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, (screenWidth * 0.20)/2, for: .scrollContent)
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
    let action: () -> Void
    
    var body: some View {
        VStack (spacing: 10) {
            
            Text(suggestion.symbol)
                .font(.system(size: 35))
                .padding(.bottom, 10)

            Text(suggestion.title)
                .multilineTextAlignment(.center)
                .font(.system(size: 17))
                .foregroundStyle(AppColors.whiteDefault)
            
            Text(suggestion.suggestionDescription)
                .multilineTextAlignment(.center)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                .padding(.bottom, 40)
            
            RectangleButtonYellow(
                buttonText: "Choose",
                action: {
                    action()
                })
        }
        .padding()
        .padding(.top, 20)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.whiteDefault.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.black5)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        }
        
    }
}

