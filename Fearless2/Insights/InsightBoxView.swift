//
//  InsightBoxView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/19/24.
//

import SwiftUI

struct InsightBoxView: View {
    @ObservedObject var insight: Insight
    
    var body: some View {
        HStack (spacing: 2) {
            VStack (alignment: .leading, spacing: 15) {
                
                Text(insight.insightContent)
                    .font(.system(size: 17))
                    .foregroundStyle(AppColors.whiteDefault)
                
                
                
                Text(DateFormatter.displayString2(from: DateFormatter.incomingFormat.date(from: insight.insightCreatedAt) ?? Date()))
                    .font(.system(size: 11))
                    .fontWeight(.light)
                    .foregroundStyle(AppColors.whiteDefault)
                    .opacity(0.5)
                
            }//VStack
            Spacer()
        }//HStack
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(AppColors.darkBrown)
        }
    }
}
