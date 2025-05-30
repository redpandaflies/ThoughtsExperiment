//
//  NewGoalExpectationsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/14/25.
//
import Mixpanel
import OSLog
import SwiftUI

struct NewGoalExpectationsView: View {
    
    @Binding var expectationsScrollPosition: Int?
    
    let expectations: [NewGoalExpectation] = NewGoalExpectation.expectations
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 10) {
            
            Text("How this works")
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom)
                .padding(.horizontal)
            
            CarouselView(items: expectations, scrollPosition: $expectationsScrollPosition, pagesCount: expectations.count) { index, expectation in
                CarouselBox(
                    orderIndex: index + 1,
                    content: expectation.content,
                    showGrid: index == 1
                )
            }
            .padding(.horizontal, 15)
            
        }//VStack
        .padding(.bottom)
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
}


