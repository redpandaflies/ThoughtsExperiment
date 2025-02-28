//
//  OnboardingIntroView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/25/25.
//

import SwiftUI

struct OnboardingIntroView: View {
    @Binding var selectedTab: Int
    @Binding var selectedIntroPage: Int
    @Binding var categoriesScrollPosition: Int?
    var categories: FetchedResults<Category>
    var content: OnboardingIntroContent {
        return OnboardingIntroContent.pages[selectedIntroPage]
    }
    
    var body: some View {
        VStack (spacing: 30) {
            
            if selectedIntroPage == 2 {
                CategoriesScrollView(categoriesScrollPosition: $categoriesScrollPosition, categories: categories)
                    .scrollDisabled(true)
                
            } else {
                Text(content.emoji)
                    .font(.system(size: 50))
            }
            
            Text(content.title)
                .multilineTextAlignment(.center)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
            
            if selectedIntroPage == 6 {
                Text(content.description)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(AppColors.textPrimary)
                    .lineSpacing(1.3)
            }
            
            Spacer()
            
            RoundButton(buttonImage: "arrow.right", size: 30, frameSize: 100, buttonAction: {
                introViewButtonAction()
            })
            
            if selectedIntroPage == 6 {
                getFooter()
            }
            
        }
        .padding(.horizontal, 25)
        .padding(.top, 140)
        .padding(.bottom, 60)
        
    }
    
    private func introViewButtonAction() {
        
        
        switch selectedIntroPage {
            case 6, 7:
                selectedTab = 1
            case 8:
                selectedTab = 3
            default:
                break
        }
        
        if selectedIntroPage < 8 {
            selectedIntroPage += 1
        }
        
    }
    
    private func getFooter() -> some View {
        Text("Everything is private. Our team can’t see your content.")
            .multilineTextAlignment(.center)
            .font(.system(size: 15, weight: .thin))
            .fontWidth(.condensed)
            .foregroundStyle(AppColors.textPrimary)
    }
}

