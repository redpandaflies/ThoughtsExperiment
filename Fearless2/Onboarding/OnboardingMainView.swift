//
//  OnboardingMainView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 2/24/25.
//
import CoreData
import SwiftUI

struct OnboardingMainView: View {
    @EnvironmentObject var viewModelFactoryMain: ViewModelFactoryMain
    @EnvironmentObject var dataController: DataController
    @State private var selectedIntroPage: Int = 0
    @State private var showNewGoalSheet: Bool = false
    @State private var cancelledCreateNewCategory: Bool = false
    @State private var animationStage: Int = 0
    let introContent: [OnboardingIntroContent] = OnboardingIntroContent.pages
    
    @AppStorage("currentAppView") var currentAppView: Int = 0
    
    var body: some View {
        
        VStack {
            
            OnboardingIntroView (
                selectedIntroPage: $selectedIntroPage,
                showNewGoalSheet: $showNewGoalSheet,
                animationStage: $animationStage
            )

        }
        .ignoresSafeArea(.keyboard)
        .background {
            BackgroundNewGoal(animationStage: $animationStage, backgroundColor: AppColors.backgroundOnboardingIntro, newBackgroundColor: AppColors.allBackgrounds[0])
        }
//        .onAppear {
//            //reset all appstorage and cloudstorage vars
////            currentCategory = 0
////            currentAppView = 0
////            unlockNewCategory = false
////            showTopics = false
////            discoveredFirstCategory = false
////            firstFocusArea = false
//            
//            Task {
////                if !categories.isEmpty {
////                    
////                    await dataController.deleteAll()
////                    
////                }
//                
//            }
//        }
        .onChange(of: showNewGoalSheet) {
            if !showNewGoalSheet && !cancelledCreateNewCategory {
                completeOnboarding()
            }
        }
        .fullScreenCover(isPresented: $showNewGoalSheet, onDismiss: {
            showNewGoalSheet = false
        }) {
            NewGoalView (
                newGoalViewModel: viewModelFactoryMain.makeNewGoalViewModel(),
                showNewGoalSheet: $showNewGoalSheet,
                cancelledCreateNewCategory: $cancelledCreateNewCategory,
                backgroundColor: AppColors.backgroundOnboardingIntro
            )
                
        }
    }
    
    private func completeOnboarding() {
        
        //hide text and button
        animationStage += 1
        
        
        //start expanding circle animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            animationStage += 1
            
            //switch to main app view
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                currentAppView = 1
            }
            
        }
        
    }
  
}


//#Preview {
//    OnboardingMainView()
//}
