//
//  QuestionsProgressBar.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/9/24.
//

import SwiftUI

struct QuestionsProgressBar: View {
    
    @Binding var currentQuestionIndex: Int
    let wholeBarWidth: CGFloat = UIScreen.current.bounds.width * 0.7
    let totalQuestions: Int
   
    var progressBarWidth: CGFloat {
        if totalQuestions > 0 {
            let barWidth = (wholeBarWidth/CGFloat (totalQuestions)) * CGFloat(currentQuestionIndex + 1)
            
            return barWidth
        } else {
            return wholeBarWidth
        }
    }
    
    let xmarkAction: () -> Void 
    
    var body: some View {
        
        HStack (spacing: 30) {
            ZStack (alignment: .leading) {
                RoundedRectangle(cornerRadius: 50)
                    .fill(Color.black.opacity(0.2))
                    .frame(width: wholeBarWidth, height: 15)
                
                
                RoundedRectangle(cornerRadius: 50)
                    .fill(AppColors.yellow1)
                    .frame(width: progressBarWidth, height: 15)
                
            }//ZStack)
            
            Spacer()
            
            Button {
                xmarkAction()
            } label: {
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(AppColors.whiteDefault.opacity(0.2))
            }
    
        }//HStack
        .padding(.vertical)
        
    }
}

//#Preview {
//    TestProgressBar()
//}
