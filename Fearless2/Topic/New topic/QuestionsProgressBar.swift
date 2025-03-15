//
//  QuestionsProgressBar.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/9/24.
//

import SwiftUI

struct QuestionsProgressBar: View {
    
    @Binding var currentQuestionIndex: Int
    
    let totalQuestions: Int
    let showBackButton: Bool
    let showXmark: Bool
    let xmarkAction: () -> Void
    let backAction: () -> Void
    
    let screenWidth = UIScreen.current.bounds.width
    
    var frame: CGFloat {
        return screenWidth - 64
    }
    
    var wholeBarWidth: CGFloat {
        return frame * 0.85
    }
   
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
    
    init(currentQuestionIndex: Binding<Int>, totalQuestions: Int, showXmark: Bool = false, xmarkAction: @escaping () -> Void = {}, showBackButton: Bool = false, backAction: @escaping () -> Void = {}) {
        self._currentQuestionIndex = currentQuestionIndex
        self.totalQuestions = totalQuestions
        self.showXmark = showXmark
        self.xmarkAction = xmarkAction
        self.showBackButton = showBackButton
        self.backAction = backAction
    }
    
    var body: some View {
        
        HStack (spacing: 0) {
            
            if showBackButton {
                
                Button {
                    backAction()
                    
                } label: {
                    
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 25))
                        .foregroundStyle(AppColors.progressBarPrimary.opacity(0.3))
                }
                
                Spacer()
            }
            
      
            
            ZStack (alignment: .leading) {
                RoundedRectangle(cornerRadius: 50)
                    .fill(AppColors.progressBarPrimary.opacity(0.3))
                    .frame(width: wholeBarWidth, height: 10)
                
                
                RoundedRectangle(cornerRadius: 50)
                    .fill(AppColors.progressBarPrimary)
                    .frame(width: progressBarWidth, height: 10)
                    .contentTransition(.interpolate)
                
            }//ZStack
            
            Spacer()
            
            Button {
                xmarkAction()
            } label: {
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(AppColors.progressBarPrimary.opacity(0.3))
                    .opacity(showXmark ? 1 : 0)
            }
    
        }//HStack
        .frame(width: screenWidth - 32)
        .padding(.top)
        .padding(.bottom, 15)
       
        
    }

}

//#Preview {
//    TestProgressBar()
//}
