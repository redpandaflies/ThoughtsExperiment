//
//  OnboardingMainView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/24/25.
//
import CloudStorage
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
    
    @CloudStorage("currentAppView") var currentAppView: Int = 0
    @CloudStorage("unlockNewCategory") var unlockNewCategory: Bool = false
    @CloudStorage("seenTutorialFirstCategory") var seenTutorialFirstCategory: Bool = false
    @CloudStorage("discoveredFirstFocusArea") var firstFocusArea: Bool = false
    @AppStorage("currentCategory") var currentCategory: Int = 0
    @AppStorage("showTopics") var showTopics: Bool = false
    
    var body: some View {
        
        VStack {
            
            HStack {
                Spacer()
                
                Button {
                    withAnimation {
                        selectedIntroPage = 9
                        imagesScrollPosition = 9
                    }
                    
                } label: {
                    Text("Skip")
                        .font(.system(size: 15))
                        .foregroundStyle(AppColors.textPrimary.opacity(0.5))
                }
                
            }
            .padding(.horizontal)
            .padding(.top, 45)
            
            OnboardingIntroView(selectedIntroPage: $selectedIntroPage, imagesScrollPosition: $imagesScrollPosition, showQuestionsView: $showQuestionsView, animationStage: $animationStage)

        }
        .ignoresSafeArea()
        .background {
            BackgroundNewCategory(animationStage: $animationStage, backgroundColor: AppColors.backgroundOnboardingIntro, newBackgroundColor: newCategory.background)
        }
        .onAppear {
            //reset all appstorage and cloudstorage vars
//            currentCategory = 0
//            currentAppView = 0
//            unlockNewCategory = false
//            showTopics = false
//            seenTutorialFirstCategory = false
//            firstFocusArea = false
            
            Task {
//                if !categories.isEmpty {
//                    
//                    await dataController.deleteAll()
//                    
//                }
                    
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
