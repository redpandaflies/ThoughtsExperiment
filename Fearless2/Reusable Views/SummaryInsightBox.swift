//
//  SummaryInsightBox.swift
//  Tinyverse
//
//  Created by Yue Deng-Wu on 10/23/24.
//

import SwiftUI

struct SummaryInsightBox: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var insight: Insight
    
    var body: some View {
        HStack (spacing: 10){
                
            
            Text(insight.insightContent)
                .font(.system(size: 15))
                .foregroundStyle(insight.markedSaved ? Color.black : AppColors.whiteDefault)
                .fixedSize(horizontal: false, vertical: true)
                
            Spacer()
            
            Image(systemName: insight.markedSaved ? "checkmark.circle.fill" : "plus.circle")
                .font(.system(size: 20))
                .fontWeight(.light)
                .foregroundStyle(insight.markedSaved ? Color.black : AppColors.whiteDefault)
                .contentTransition(.symbolEffect(.replace.offUp.byLayer))
             

        }//HStack
        .padding()
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(insight.markedSaved ? AppColors.yellow1 : AppColors.whiteDefault)
                .fill(insight.markedSaved ? AppColors.yellow1 : Color.clear)
                
        }
        .onTapGesture {
            saveInsight()
        }
    }
    
    private func saveInsight() {
        Task { @MainActor in
            insight.markedSaved.toggle()
            await dataController.save()
        }
    }
}

//#Preview {
//    InsightBoxView()
//}
