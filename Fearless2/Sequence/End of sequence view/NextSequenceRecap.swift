//
//  NextSequenceRecap.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/16/25.
//

import SwiftUI

struct NextSequenceRecap: View {
    @ObservedObject var sequenceViewModel: SequenceViewModel
    
    @State private var recapSelectedTab: Int = 0
  
    @State private var recapScrollPosition: Int?
    
    let summaries: [SequenceSummary]
    
    let retryAction: () -> Void
    
    var sortedSummaries: [SequenceSummary] {
        return summaries.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var body: some View {
        VStack {
            switch recapSelectedTab {
            case 0:
                LoadingPlaceholderContent(contentType: .recap)
                
            case 1:
                CarouselView(
                    items: sortedSummaries,
                    scrollPosition: $recapScrollPosition,
                    pagesCount: sortedSummaries.count
                ) { index, summary in
                    CarouselBox(orderIndex: index + 1, content: summary.summaryContent)
                }
                
            default:
                FocusAreaRetryView(action: {
                    retryAction()
                })
                
            }
        }
        .onAppear {
            switch sequenceViewModel.createSequenceSummary {
            case .ready:
                recapSelectedTab = 1
            case .loading:
                if recapSelectedTab != 0 {
                    recapSelectedTab = 0
                }
            case .retry:
                recapSelectedTab = 2
            }
        }
        .onChange(of: sequenceViewModel.createSequenceSummary) {
            switch sequenceViewModel.createSequenceSummary {
            case .ready:
                recapSelectedTab = 1
            case .loading:
                if recapSelectedTab != 0 {
                    recapSelectedTab = 0
                }
            case .retry:
                recapSelectedTab = 2
            }
        }
        
    }
    
  
}



