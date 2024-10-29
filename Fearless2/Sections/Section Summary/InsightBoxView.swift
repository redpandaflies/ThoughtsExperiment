//
//  InsightBoxView.swift
//  Tinyverse
//
//  Created by Yue Deng-Wu on 10/23/24.
//

import SwiftUI

struct InsightBoxView: View {
    
    @ObservedObject var insight: Insight
    
    var body: some View {
        HStack (alignment: .top, spacing: 10){
           
            Image(systemName: "plus.circle")
                .font(.system(size: 20))
                .fontWeight(.light)
                .foregroundStyle(AppColors.sectionSummaryDark)
                .contentTransition(.symbolEffect(.replace.offUp.byLayer))
                
            HStack {
                Text(insight.insightContent)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundStyle(AppColors.blackDefault)
                    .fixedSize(horizontal: false, vertical: true)
                    
                
                Spacer()
            }//HStack
           

        }//HStack
        .padding(.vertical)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColors.sectionSummaryOffWhite)
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        }
    }
}

//#Preview {
//    InsightBoxView()
//}
