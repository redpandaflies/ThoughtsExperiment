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
    @Binding var selectedTab: Int //navigate to next tab in parent view
    @Binding var topicId: UUID?
    let selectedPage: SectionRecapTabs
    let selectedCategory: TopicCategoryItem
    
    
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack {
                BubblesCategory(selectedCategory: selectedCategory, useFullName: true)
                
                Spacer()
            }
            
            Text("Section Recap")
                .multilineTextAlignment(.leading)
                .font(.system(size: 13))
                .fontWeight(.regular)
                .foregroundStyle(AppColors.blackDefault)
                .padding(.bottom, 5)
            
            Divider()
            
            switch selectedPage {
            case .reflection:
                if let currentTopicId = topicId {
                    SectionReflectionQuestions(topicId: currentTopicId)
                }
                
            case .suggestions:
                SectionSuggestionsView(selectedOptions: $selectedOptions, items: topicViewModel.sectionSuggestions)
            }
            
            
            HStack {
                
                Spacer()
                
                Button {
                    
                    saveAnswer()
                    
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.blackDefault)
                }
            }
            
        }//Vstack
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.07), radius: 3, x: 0, y: 1)
            
        }
    }
    
    private func saveAnswer() {
        selectedTab += 1
        
        Task {
            
            switch selectedPage {
            case .reflection:
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
