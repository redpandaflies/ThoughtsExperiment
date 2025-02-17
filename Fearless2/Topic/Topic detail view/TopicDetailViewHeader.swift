//
//  TopicDetailViewHeader.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/24/24.
//

import SwiftUI

struct TopicDetailViewHeader: View {
    
    let title: String
    let progress: Int
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        VStack (spacing: 10){
            
            Text(title)
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.whiteDefault)
                .padding(.horizontal)
            
            TopicDetailViewProgressBar(progress: progress)
        }
        .padding(.top)
        .frame(width: screenWidth)
    }
}

struct TopicDetailViewProgressBar: View {
    let progress: Int
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        VStack (spacing: 10){
            
            ZStack {
                Image("squiggleLine")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.5)
                
                Image("squiggleLine")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle()
                                .frame(width: calculateProgressWidth(totalWidth: screenWidth))
                            Rectangle()
                                .frame(width: screenWidth - calculateProgressWidth(totalWidth: screenWidth))
                                .opacity(0)
                        }
                    )
                    
            }
            
            TopicDetailViewProgressBarLabels(progress: progress)
        }
    }
    
    private func calculateProgressWidth(totalWidth: CGFloat) -> CGFloat {
            let segmentWidth = (totalWidth / 10)
            return (segmentWidth * CGFloat(progress))
        }
    
}

struct TopicDetailViewProgressBarLabels: View {
    
    let progress: Int
    
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
            
        HStack (spacing: 0) {
            
            ForEach(1...4, id: \.self) { index in
                
                getNumber(index: index)
                    .frame(width: screenWidth/10)
                    .opacity(index <= progress ? 1 : 0.4)
                
                
            }
            
            getSymbol(symbolName: "arrow.triangle.branch")
                .frame(width: screenWidth/10)
                .opacity(progress >= 5 ? 1 : 0.4)
            
            ForEach(5...7, id: \.self) { index in
                
                getNumber(index: index)
                    .frame(width: screenWidth/10)
                    .opacity((index <= progress + 1) ? 1 : 0.4)
                
            }
            
            HStack (spacing: 2) {
                getSymbol(symbolName: "laurel.leading")
                
                getSymbol(symbolName: "laurel.trailing")
                
            }
            .frame(width: screenWidth/10)
            .opacity(progress >= 9 ? 1 : 0.4)
            
        }//HStack
    }
    
    private func getNumber(index: Int) -> some View {
        Text("\(index)")
            .multilineTextAlignment(.center)
            .font(.system(size: 13))
            .fontWidth(.condensed)
            .foregroundStyle(AppColors.textPrimary)
    }
    
    private func getSymbol(symbolName: String) -> some View {
        Image(systemName: symbolName)
        .font(.system(size: 13))
        .foregroundStyle(AppColors.textPrimary)
    }
}

#Preview {
    TopicDetailViewProgressBar(progress: 5)
}
