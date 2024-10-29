//
//  SummaryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//

import SwiftUI

struct SummaryView: View {
    @Environment(\.dismiss) var dismiss
    let topic: Topic
    
    var body: some View {
        NavigationStack {
                   
                   ScrollView {
                       VStack(alignment: .leading, spacing: 10) {
                           
                           SummarySectionView(title: "Summary", content: topic.topicSummary)
                          SummarySectionView(title: "People", content: topic.topicPeople)
                          SummarySectionView(title: "Emotions", content: topic.topicEmotions)
                        
                       }//HStack
                       .padding(.horizontal, 40)
                       .padding(.top, 20)
                 
                   }
                   .scrollIndicators(.hidden)
                   .navigationBarTitleDisplayMode(.inline)
                   .toolbar {
                       ToolbarItem(placement: .topBarTrailing) {
                           Button {
                               dismiss()
                              
                               
                           } label: {
                               Text("Done")
                                   .foregroundStyle(AppColors.blackDefault)
                           }
                       }
                   }
               }
               .ignoresSafeArea(.keyboard)
               
    }
       
}

struct SummarySectionView: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .foregroundStyle(AppColors.blackDefault)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }

            Group {
                if !content.isEmpty {
                    Text(content)
                } else {
                    Text("No data available.")
                }
            }
            .foregroundStyle(AppColors.blackDefault)
            .font(.headline)
            .fontWeight(.regular)
            .lineSpacing(1.3)
            .padding(.bottom)
        }
    }
}

//#Preview {
//    SummaryView()
//}
