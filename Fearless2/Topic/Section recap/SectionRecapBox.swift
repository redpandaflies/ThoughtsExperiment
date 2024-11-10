//
//  SectionReflectionBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/30/24.
//

import SwiftUI

enum SectionRecapTabs {
    case reflection
    case suggestions
}

struct SectionRecapBox: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedOptions: [String] = [] //user's choice for what they want to focus on next
    @State private var currentQuestionIndex = 0 //for the progress bar
    @Binding var selectedTab: Int //navigate to next tab in parent view
    let topicId: UUID?
    let selectedPage: SectionRecapTabs
    let selectedCategory: TopicCategoryItem
    
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            VStack (alignment: .leading, spacing: 5) {
                Text("Section Recap")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(selectedCategory.getCategoryColor())
                    .textCase(.uppercase)
                
                
                switch selectedPage {
                case .reflection:
                    if let currentTopicId = topicId {
                        SectionReflectionQuestions(topicId: currentTopicId, selectedCategory: selectedCategory)
                    }
                    
                case .suggestions:
                    SectionSuggestionsView(selectedOptions: $selectedOptions, items: topicViewModel.sectionSuggestions)
                }
                
                Spacer()
                
            }//VStack
            .padding()
            .padding(.top)
            .frame(height: 340)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.questionBoxBackground)
                    .shadow(color: .black.opacity(0.07), radius: 3, x: 0, y: 1)
                
            }
            
            QuestionsProgressBar(currentQuestionIndex: $currentQuestionIndex, questionCount: 2, action: { saveAnswer()})
            
        }//Vstack
        
    }
    
    private func saveAnswer() {
        selectedTab += 1
        
        
        Task {
            
            switch selectedPage {
            case .reflection:
                currentQuestionIndex += 1
                await dataController.save()
                //API call to AI assistant for suggestions
                await topicViewModel.manageRun(selectedAssistant: .sectionSuggestions, category: selectedCategory, topicId: topicId)
                
            case .suggestions:

                await topicViewModel.manageRun(selectedAssistant: .focusArea, category: selectedCategory, userInput: selectedOptions, topicId: topicId)
                
            }
        }
        
    }
    
}

//#Preview {
//    SectionReflectionBox()
//}
