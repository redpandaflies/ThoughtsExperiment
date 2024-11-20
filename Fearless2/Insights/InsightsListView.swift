//
//  InsightsListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/19/24.
//

import CoreData
import SwiftUI

struct InsightsListView: View {
    @Binding var selectedEntry: Entry?
    
    let topicId: UUID
    @FetchRequest var insights: FetchedResults<Insight>
    
    init(selectedEntry: Binding<Entry?>, topicId: UUID) {
        _selectedEntry = selectedEntry
        self.topicId = topicId
        
        let request: NSFetchRequest<Insight> = Insight.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let savedPredicate = NSPredicate(format: "markedSaved == YES")
        let topicPredicate = NSPredicate(format: "topic.id == %@", topicId as CVarArg)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [topicPredicate, savedPredicate])
        request.predicate = compoundPredicate
       
        self._insights = FetchRequest(fetchRequest: request)
    }
    
    var body: some View {
        VStack (spacing: 10) {
            ForEach(insights, id: \.insightId) { insight in
                InsightBoxView(insight: insight)
                    .onTapGesture {
                        if let entry = insight.entry {
                            selectedEntry = entry
                        }
                    }
            }
            
        }
        
    }
}