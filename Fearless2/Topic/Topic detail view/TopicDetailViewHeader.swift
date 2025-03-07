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
    let topic: Topic
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        VStack (spacing: 20){
            
            Text(title)
                .multilineTextAlignment(.center)
                .font(.system(size: 17, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal)
            
            TopicDetailViewProgressBar(progress: progress, topic: topic)
        }
        .padding(.top)
        .frame(width: screenWidth)
    }
}

struct TopicDetailViewProgressBar: View {
    let progress: Int
    let topic: Topic
    let screenWidth = UIScreen.current.bounds.width
    var frameWidth: CGFloat {
        return screenWidth/CGFloat(topic.focusAreasLimit + 2)
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
                                .frame(width: topic.completed ? screenWidth : progressWidth)
                            Rectangle()
                                .frame(width: topic.completed ? 0 : screenWidth - progressWidth)
                                .opacity(0)
                        }
                    )
                    
            }
            
            TopicDetailViewProgressBarLabels(progress: progress, focusAreasLimit: Int(topic.focusAreasLimit), frameWidth: frameWidth)
        }
    }
    
}

struct TopicDetailViewProgressBarLabels: View {
    
    let progress: Int
    let focusAreasLimit: Int
    var frameWidth: CGFloat
    
    var body: some View {
            
        HStack (spacing: 0) {
            
            ForEach(1...focusAreasLimit, id: \.self) { index in
                
                getNumber(index: index)
                    .frame(width: frameWidth)
                    .opacity(index <= progress ? 1 : 0.4)
                
                
            }
            
            HStack (spacing: 5) {
                getSymbol(symbolName: "laurel.leading")
                
                getSymbol(symbolName: "laurel.trailing")
                
            }
            .frame(width: frameWidth)
            .opacity(progress >= (focusAreasLimit + 1) ? 1 : 0.4)
            
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
