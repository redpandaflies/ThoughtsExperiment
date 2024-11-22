//
//  UnderstandQuestionAnswer.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/21/24.
//

import SwiftUI

struct UnderstandQuestionAnswer: View {
    let understand: Understand
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            
            VStack (alignment: .leading, spacing: 10) {
                
                Text(DateFormatter.displayString(from: DateFormatter.incomingFormat.date(from: understand.understandCreatedAt) ?? Date()))
                    .font(.system(size: 12))
                    .fontWeight(.light)
                    .foregroundStyle(AppColors.understandYellow.opacity(0.5))
                    .textCase(.uppercase)
                    .opacity(0.5)
                
             
                Text(understand.understandQuestion)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 25))
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.whiteDefault)
                    .padding(.bottom)
                
                Text(understand.understandAnswer)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.whiteDefault)
                    .lineSpacing(3)
                    .padding(.bottom)
                
                
            }//VStack
            .padding()
        }//ScrollView
    }
}


