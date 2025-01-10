//
//  FocusAreaRecapHeader.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/9/24.
//

import SwiftUI

struct FocusAreaRecapHeader: View {
    
    @Binding var selectedTab: Int
    let topicTitle: String
 
    let xmarkAction: () -> Void
    
    let showSuggestions: Bool
    
    var progressBarRange: Range<Int> {
        showSuggestions ? 1..<4 : 1..<3
    }
    
    var body: some View {
        
        HStack (spacing: 30) {
            switch selectedTab {
            case 0:
                showTopicTitle()
            default:
                progressBar()
            }
            
            Spacer()
            
            Button {
                xmarkAction()
            } label: {
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(AppColors.whiteDefault.opacity(0.3))
            }
    
        }//HStack
        .padding(.vertical)
        
    }
    
    private func showTopicTitle() -> some View {
        Text(topicTitle)
            .font(.system(size: 16, weight: .light).smallCaps())
            .fontWidth(.condensed)
            .foregroundStyle(AppColors.whiteDefault.opacity(0.5))
    }
    
    private func progressBar() -> some View {
        HStack {
            ForEach(progressBarRange, id: \.self) { index in
                RoundedRectangle(cornerRadius: 50)
                    .fill((index <= selectedTab) ? AppColors.yellow1 : AppColors.whiteDefault.opacity(0.5) )
                    .frame(width: 40, height: 5)
                
            }
        }//HStack
    }
}

//#Preview {
//    TestProgressBar()
//}
