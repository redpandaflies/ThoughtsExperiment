//
//  InsightBoxView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/19/24.
// insight box for the insights list

import SwiftUI

struct InsightBoxView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var insight: Insight
    
    var body: some View {
        
        HStack {
            
            Text(insight.insightContent)
                .multilineTextAlignment(.leading)
                .font(.system(size: 14))
                .foregroundStyle(AppColors.whiteDefault)
                .lineSpacing(0.75)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 12)
            
            Spacer()
            
            Menu {
                Button (role: .destructive) {
                    unsaveInsight()
                } label: {
                    Label("Remove insight", systemImage: "lightbulb.slash")
                }
                
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.whiteDefault.opacity(0.5))
                    .padding(.vertical, 12)
                    .padding(.trailing, 12)
                    .padding(.leading, 5)
            }
           
        }//HStack
        .padding(.leading, 12)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppColors.whiteDefault.opacity(0.2))
                .fill(AppColors.black3)
                .shadow(color: .black.opacity(0.3), radius: 0, x: 0, y: 3)
        }
    }
    
    private func unsaveInsight() {
        Task { @MainActor in
            insight.markedSaved = false
            await dataController.save()
        }
    }
}
