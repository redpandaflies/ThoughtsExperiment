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
  
    @Binding var recapScrollPosition: Int?
    @Binding var showExitFlowAlert: Bool
    
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
                .padding(.horizontal, -1)
                
            default:
                FocusAreaRetryView(action: {
                    retryAction()
                })
                
            }
        }
        .onAppear {
            manageView()
        }
        .onChange(of: sequenceViewModel.createSequenceSummary) {
            manageView()
        }
        .onChange(of: showExitFlowAlert) {
            // in case API call finishes while alert is active & view doesn't update
            
            if !showExitFlowAlert  {
                manageView()
            }
        }
        
    }
    
    private func manageView() {
        switch sequenceViewModel.createSequenceSummary {
        case .ready:
            if recapSelectedTab != 1 {
                recapSelectedTab = 1
            }
        case .loading:
            if recapSelectedTab != 0 {
                recapSelectedTab = 0
            }
        case .retry:
            if recapSelectedTab != 2 {
                recapSelectedTab = 2
            }
        }
    }
}



