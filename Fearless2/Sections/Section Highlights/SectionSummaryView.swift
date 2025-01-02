//
//  SectionSummaryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/29/24.
//

import SwiftUI

struct SectionSummaryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var summary: SectionSummary
    
    var body: some View {
        
        ZStack {
            ScrollView (showsIndicators: false) {
                VStack (spacing: 5) {
                    
                    Text(summary.section?.focusArea?.focusAreaTitle ?? "")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.whiteDefault)
                        .textCase(.uppercase)
                        .opacity(0.5)
                        .padding(.top)
                    
                    Text(summary.section?.sectionTitle ?? "")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(AppColors.whiteDefault)
                        .padding(.bottom, 40)
                    
                    
                    
                    VStack (alignment: .leading, spacing: 15) {
                        
                        Text("Save Insights")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.yellow1)
                            .textCase(.uppercase)
                        
                        ForEach(summary.summaryInsights, id: \.insightId) { insight in
                            
                            SummaryInsightBox(insight: insight)
                        }
                    }
                    
                }//Vstack
                
            }//Scrollview
            .scrollDisabled(true)
            
            VStack (spacing: 20) {
                Spacer()
                
                RectangleButton(buttonImage: "arrow.right.circle.fill", buttonColor: AppColors.whiteDefault)
                    
                    .onTapGesture {
                        closeView()
                    }
                
                Text("Find your saved insights on the Insights tab of each topic.")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.whiteDefault)
                    .opacity(0.5)
                
            }
            .padding(.bottom, 50)
            
        }//ZStack
        .padding()
    }
    
    private func closeView() {
        dismiss()
        
        if let section = summary.section {
            Task {
                if !section.completed {
                    section.completed = true
                    await dataController.save()
                }
            }
        }
    }
}


