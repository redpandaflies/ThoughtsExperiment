//
//  TopicBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/7/24.
//

import SwiftUI

struct TopicBox: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @ObservedObject var topic: Topic
    let buttonAction: () -> Void
    var latestFocusArea: FocusArea? {
        let sortedFocusArea = topic.topicFocusAreas.sorted { $0.focusAreaCreatedAt < $1.focusAreaCreatedAt }
        return sortedFocusArea.last
    }
    
    var totalFocusAreas: Int {
        return topic.topicFocusAreas.count
    }
    
    var body: some View {
            
        VStack (spacing: 5){
            
            Text(topic.topicTitle)
                .multilineTextAlignment(.center)
                .font(.system(size: 21, design:.serif))
                .foregroundStyle(AppColors.whiteDefault)
                .lineSpacing(0.5)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
                .overlay(AppColors.dividerPrimary.opacity(0.4))
                .shadow(color: AppColors.dividerShadow.opacity(0.05), radius: 0, x: 0, y: 1)
                .padding(.vertical, 20)
            
            Text("Path \(totalFocusAreas)")
                .font(.system(size: 17, weight: .light))
                .fontWidth(.condensed)
                .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                .textCase(.uppercase)
            
            Text(latestFocusArea?.focusAreaTitle ?? "")
                .multilineTextAlignment(.center)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                .padding(.bottom)
            
            NextButtonRound(buttonAction: {
                
            })
              
        
        }//VStack
        .padding()
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.backgroundPrimary.opacity(0.3))
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(.softLight)
                
        }

    }
    
    
}

struct NextButtonRound: View {
    let buttonAction: () -> Void
    
    var body: some View {
        
        Button {
            buttonAction()
            
        } label: {
            Image(systemName: "arrow.right")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color.black)
                .padding(20)
                .background {
                    Circle()
                        .stroke(Color.white.opacity(0.9))
                        .fill(
                            LinearGradient(
                            stops: [
                            Gradient.Stop(color: .white, location: 0.00),
                            Gradient.Stop(color: AppColors.buttonPrimary, location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 3)
                }
        }
       
    }
}

//#Preview {
//    TopicBox()
//}
