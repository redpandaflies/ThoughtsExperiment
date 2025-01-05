//
//  FocusAreaRecapHeader.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/9/24.
//

import SwiftUI

struct FocusAreaRecapHeader: View {
    
    @Binding var selectedTab: Int
    let focusAreaTitle: String
 
    let xmarkAction: () -> Void
    
    let showSuggestions: Bool
    
    var progressBarRange: Range<Int> {
        showSuggestions ? 1..<4 : 1..<3
    }
    
    var body: some View {
        
        HStack (spacing: 30) {
            switch selectedTab {
            case 0:
                showFocusAreaTitle()
            default:
                progressBar()
            }
            
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
    
    private func showFocusAreaTitle() -> some View {
        Text(focusAreaTitle)
            .font(.system(size: 14))
            .foregroundStyle(AppColors.whiteDefault.opacity(0.5))
            .textCase(.uppercase)
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
