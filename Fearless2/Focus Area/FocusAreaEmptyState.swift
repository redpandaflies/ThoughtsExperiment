//
//  FocusAreaEmptyState.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/23/24.
//

import CoreData
import SwiftUI

struct FocusAreaEmptyState: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @Binding var selectedTab: Int
    let topicId: UUID
    
    @FetchRequest var suggestions: FetchedResults<FocusAreaSuggestion>
    
    init(topicViewModel: TopicViewModel, selectedTab: Binding<Int>, topicId: UUID) {
        self.topicViewModel = topicViewModel
        self._selectedTab = selectedTab
        self.topicId = topicId
        
        let request: NSFetchRequest<FocusAreaSuggestion> = FocusAreaSuggestion.fetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "topic.id == %@", topicId as CVarArg)
        self._suggestions = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            
            HStack {
                Text("What would you like to focus on?")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 19))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 10)
                
                Spacer()
                
            }
            
            Text("Select one")
                .multilineTextAlignment(.leading)
                .font(.system(size: 11))
                .fontWeight(.light)
                .foregroundStyle(Color.white)
                .textCase(.uppercase)
            
            ForEach(suggestions, id: \.suggestionId) { suggestion in
                suggestionBox(suggestion.suggestionContent)
                    .onTapGesture {
                        createFocusArea(suggestion.suggestionContent)
                    }
            }
            
        }
        .padding(.horizontal, 30)
        
    }
    
    private func suggestionBox(_ suggestion: String) -> some View {
       
        HStack (spacing: 5) {
            Text(suggestion)
                .font(.system(size: 16))
                .foregroundStyle(Color.white)
                .fontWeight(.light)
                .textCase(.lowercase)
                .fixedSize(horizontal: true, vertical: true)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white, lineWidth: 1)
                .fill(Color.clear)
        }
    }
    
    private func createFocusArea(_ suggestion: String) {
        selectedTab += 1
        Task {
            await topicViewModel.manageRun(selectedAssistant: .focusArea, userInput: [suggestion], topicId: topicId)
        }
    }
}
