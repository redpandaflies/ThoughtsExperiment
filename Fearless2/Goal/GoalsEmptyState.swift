//
//  GoalsEmptyState.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 5/7/25.
//

import SwiftUI

struct GoalsEmptyState: View {
    
    let sampleTopics: [OnboardingSampleTopicsItem] = OnboardingSampleTopicsItem.sample
    
    let screenWidth = UIScreen.current.bounds.width
    let hStackSpacing: CGFloat = 12
    var boxFrameWidth: CGFloat {
        return (screenWidth - (2 * hStackSpacing) - 60) / 3
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10)  {
            
            SpinnerDefault()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 70)
                .padding(.horizontal, 30)
            
            Text(OnboardingIntroContent.pages[1].title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 40)
               
            
          
                HStack (spacing: hStackSpacing) {
                    ForEach(sampleTopics, id: \.id) { topic in
                       
                        SampleTopicBox(
                            heading: topic.heading,
                            title: topic.title,
                            boxFrameWidth: boxFrameWidth
                        )

                    }
                }
                .padding(.horizontal, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top)
            
        }
     
    }
}

