//
//  OnboardingMainView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/24/25.
//
import CoreData
import SwiftUI

struct OnboardingMainView: View {
    @EnvironmentObject var dataController: DataController
    @State private var selectedIntroPage: Int = 0
    @State private var imagesScrollPosition: Int?
    @State private var selectedCategory: String = ""
    @State private var showQuestionsView: Bool = false
    @State private var animationStage: Int = 0
    let introContent: [OnboardingIntroContent] = OnboardingIntroContent.pages
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "orderIndex", ascending: true)
        ]
    ) var categories: FetchedResults<Category>
    
    var newCategory: Realm {
        return QuestionCategory.getCategoryData(for: selectedCategory) ?? Realm.realmsData[6]
    }
    
    var body: some View {
        
        VStack {
            
            OnboardingIntroView(selectedIntroPage: $selectedIntroPage, imagesScrollPosition: $imagesScrollPosition, showQuestionsView: $showQuestionsView, animationStage: $animationStage)

        }
        .ignoresSafeArea()
        .background {
            BackgroundOnboarding(animationStage: $animationStage, backgroundColor: AppColors.backgroundOnboardingIntro, newBackgroundColor: newCategory.background)
        }
        .onAppear {
            
            Task {
                if !categories.isEmpty {
                    
                    await dataController.deleteAll()
                    
                }
                    
                await MainActor.run {
                    imagesScrollPosition = 0
                }
                
            }
        }
        .fullScreenCover(isPresented: $showQuestionsView, onDismiss: {
            showQuestionsView = false
        }) {
            OnboardingQuestionsView(selectedCategory: $selectedCategory, selectedIntroPage: $selectedIntroPage, imagesScrollPosition: $imagesScrollPosition)
                
        }
    }
  
}


#Preview {
    OnboardingMainView()
}
