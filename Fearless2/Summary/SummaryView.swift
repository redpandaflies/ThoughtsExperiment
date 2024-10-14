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
                          
                           Text("Fearless' reaction")
                               .foregroundStyle(AppColors.blackDefault)
                               .font(.headline)
                               .fontWeight(.semibold)

                           
                           Text(topic.topicFeedback)
                               .foregroundStyle(AppColors.blackDefault)
                               .font(.headline)
                               .fontWeight(.regular)
                               .lineSpacing(1.3)
                               .padding(.bottom)
                           
                           Text("Summary")
                               .foregroundStyle(AppColors.blackDefault)
                               .font(.headline)
                               .fontWeight(.semibold)

                           
                           Text(topic.topicSummary)
                               .foregroundStyle(AppColors.blackDefault)
                               .font(.headline)
                               .fontWeight(.regular)
                               .lineSpacing(1.3)
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

//#Preview {
//    SummaryView()
//}
