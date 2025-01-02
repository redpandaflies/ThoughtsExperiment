//
//  InsightBoxView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/19/24.
// insight box for the insights list

import SwiftUI

struct InsightBoxView: View {
    @ObservedObject var insight: Insight
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 15) {
            
            Text(insight.insightContent)
                .multilineTextAlignment(.leading)
                .font(.system(size: 17))
                .foregroundStyle(AppColors.whiteDefault)
                .lineSpacing(0.5)
            
            Spacer()
            
            HStack {
                Text(DateFormatter.displayString2(from: DateFormatter.incomingFormat.date(from: insight.insightCreatedAt) ?? Date()))
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 11))
                    .fontWeight(.light)
                    .foregroundStyle(AppColors.whiteDefault)
                    .textCase(.uppercase)
                    .opacity(0.5)
                
                Spacer()
            }
        }//VStack
        .padding(13)
        .frame(width: 150, height: 180)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(AppColors.whiteDefault.opacity(0.1))
                .fill(AppColors.black2)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        }
    }
}
