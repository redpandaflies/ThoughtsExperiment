//
//  GoalsEmptyState.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/7/25.
//
import Pow
import SwiftUI

struct GoalsEmptyState: View {

    @Binding var showNewGoalSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10)  {
            
            SpinnerDefault()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 70)
            
            Text(OnboardingIntroContent.pages[1].title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)

            
            SampleGoalsView(onTapAction: { _ in
                showNewGoalSheet = true
            })
            .padding(.top)
           
            
        }
        .padding(.horizontal, 30)
    }
}

