//
//  QuestionsProgressBar.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/9/24.
//

import SwiftUI

struct QuestionsProgressBar: View {
    
    @Binding var currentQuestionIndex: Int
    let screenWidth = UIScreen.current.bounds.width
    
    var frame: CGFloat {
        return screenWidth - 64
    }
    
    var wholeBarWidth: CGFloat {
        return frame * 0.923
    }
    
    var xmarkSize: CGFloat {
        return frame * 0.075
    }
    
    var trailingSpace: CGFloat {
        return frame * 0.002
    }
   
    let totalQuestions: Int
   
    var progressBarWidth: CGFloat {
        if totalQuestions > 0 {
            var barWidth: CGFloat = wholeBarWidth * 0.1
            
            if currentQuestionIndex > 0 {
                barWidth = (wholeBarWidth/CGFloat (totalQuestions)) * CGFloat(currentQuestionIndex)
            }
            
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
                    .fill(AppColors.progressBarPrimary.opacity(0.3))
                    .frame(width: wholeBarWidth, height: 10)
                
                
                RoundedRectangle(cornerRadius: 50)
                    .fill(AppColors.progressBarPrimary)
                    .frame(width: progressBarWidth, height: 10)
                    .contentTransition(.interpolate)
                
            }//ZStack
            .padding(.trailing, trailingSpace)
            
            Button {
                xmarkAction()
            } label: {
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: xmarkSize))
                    .foregroundStyle(AppColors.progressBarPrimary.opacity(0.3))
            }
    
        }//HStack
        .frame(width: screenWidth - 32)
        .padding(.vertical)
       
        
    }

}

//#Preview {
//    TestProgressBar()
//}
