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
        VStack (spacing: 10) {
           
            Text("Choose a starting point")
                .multilineTextAlignment(.leading)
                .font(.system(size: 20))
                .foregroundStyle(AppColors.whiteDefault)
                .padding(.vertical, 10)
            
            Text("Paths help you explore your topics. Each path is unique.")
                .multilineTextAlignment(.leading)
                .font(.system(size: 13))
                .fontWeight(.light)
                .foregroundStyle(AppColors.whiteDefault)
                .opacity(0.8)
                .padding(.bottom)
            
            FocusAreaSuggestionsList(topicViewModel: topicViewModel, suggestions: suggestions.map { $0 as any SuggestionProtocol }, action: {
                selectedTab += 1
            }, topic: suggestions.first?.topic)
        }
        
        
    }
    
    
}

