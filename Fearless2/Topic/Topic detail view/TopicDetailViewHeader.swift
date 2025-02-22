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
    let totalFocusAreas: Int
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        VStack (spacing: 10){
            
            Text(title)
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.whiteDefault)
                .padding(.horizontal)
            
            TopicDetailViewProgressBar(progress: progress, totalFocusAreas: totalFocusAreas)
        }
        .padding(.top)
        .frame(width: screenWidth)
    }
}

struct TopicDetailViewProgressBar: View {
    let progress: Int
    let totalFocusAreas: Int
    let screenWidth = UIScreen.current.bounds.width
    var frameWidth: CGFloat {
        return screenWidth/CGFloat(totalFocusAreas + 2)
    }
    
    var progressWidth: CGFloat {
            return (frameWidth * CGFloat(progress))
        }
    
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
                                .frame(width: progressWidth)
                            Rectangle()
                                .frame(width: screenWidth - progressWidth)
                                .opacity(0)
                        }
                    )
                    
            }
            
            TopicDetailViewProgressBarLabels(progress: progress, totalFocusAreas: totalFocusAreas, frameWidth: frameWidth)
        }
    }
    
}

struct TopicDetailViewProgressBarLabels: View {
    
    let progress: Int
    let totalFocusAreas: Int
    var frameWidth: CGFloat
    
    var body: some View {
            
        HStack (spacing: 0) {
            
            ForEach(1...totalFocusAreas, id: \.self) { index in
                
                getNumber(index: index)
                    .frame(width: frameWidth)
                    .opacity(index <= progress ? 1 : 0.4)
                
                
            }
            
            HStack (spacing: 2) {
                getSymbol(symbolName: "laurel.leading")
                
                getSymbol(symbolName: "laurel.trailing")
                
            }
            .frame(width: frameWidth)
            .opacity(progress >= (totalFocusAreas + 1) ? 1 : 0.4)
            
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

//#Preview {
//    TopicDetailViewProgressBar(progress: 5)
//}
