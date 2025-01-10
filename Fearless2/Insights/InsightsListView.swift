//
//  InsightsListView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/19/24.
//

import CoreData
import SwiftUI

struct InsightsListView: View {
    
    let topicId: UUID
    @FetchRequest var insights: FetchedResults<Insight>
    
    init(topicId: UUID) {
       
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
            
        VStack (spacing: 15) {
            
            HStack {
                Text("Collected insights")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 16, weight: .light))
                    .fontWidth(.condensed)
                    .foregroundStyle(AppColors.yellow1)
                    .textCase(.uppercase)
                
                Spacer()
            }
            
            if insights.isEmpty {
                InsightsEmptyState()
                
            } else {
                VStack (alignment: .leading) {
                    ForEach(insights, id: \.insightId) { insight in
                        InsightBoxView(insight: insight)
                    }
                }
            }
        }//VStack

    }
}
