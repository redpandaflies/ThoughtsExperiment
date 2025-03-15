//
//  NewCategoryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/24/25.
//
import CoreData
import SwiftUI

struct NewCategoryView: View {
    @EnvironmentObject var dataController: DataController
    @State private var selectedIntroPage: Int = 0
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
            NewCategoryIntroView(selectedIntroPage: $selectedIntroPage, showQuestionsView: $showQuestionsView, animationStage: $animationStage, categories: categories)

        }
        .ignoresSafeArea()
        .background {
            BackgroundNewCategory(animationStage: $animationStage, backgroundColor: AppColors.backgroundOnboardingIntro, newBackgroundColor: newCategory.background)
        }
        .environment(\.colorScheme, .dark )
        .fullScreenCover(isPresented: $showQuestionsView, onDismiss: {
            showQuestionsView = false
        }) {
            NewCategoryQuestionsView(selectedCategory: $selectedCategory, selectedIntroPage: $selectedIntroPage, categories: categories)
        }
    }
  
}


#Preview {
    OnboardingMainView()
}
