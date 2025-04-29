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
    @StateObject var newCategoryViewModel: NewCategoryViewModel
    @State private var mainSelectedTab: Int = 0
    @State private var selectedCategory: String = ""
    @State private var animationStage: Int = 0
    
    //State vars that retain user's answers in memory
    @State private var selectedQuestion: Int = 0
    @State private var progressBarQuestionIndex: Int = 0
    @State private var questions: [QuestionNewCategory] = QuestionNewCategory.initialQuestionsNewCategory()
    // Array to store all open question answers
    @State private var answersOpen: [String] = Array(repeating: "", count: 5)
    // Array to store all single-select question answers
    @State private var answersSingleSelect: [String] = Array(repeating: "", count: 5)
    // flag for tracking if new category has been saved, and needs to be deleted when user exits this flow early
    @State private var newGoalSaved: Bool = false
    
    @Binding var showNewGoalSheet: Bool
    @Binding var cancelledCreateNewCategory: Bool

    var body: some View {
        
        VStack (spacing: 10) {
            
            // MARK: - Header
            if mainSelectedTab > 0 {
                NewCategoryHeader(
                    mainSelectedTab: $mainSelectedTab,
                    xmarkAction: {
                        exitFlowAction()
                    })
            }
            
            // MARK: - View Content
            switch mainSelectedTab {
                case 0:
                    NewCategoryQuestionsView (
                        newCategoryViewModel: newCategoryViewModel,
                        showNewGoalSheet: $showNewGoalSheet,
                        mainSelectedTab: $mainSelectedTab,
                        selectedCategory: $selectedCategory,
                        selectedQuestion: $selectedQuestion,
                        progressBarQuestionIndex: $progressBarQuestionIndex,
                        questions: $questions,
                        answersOpen: $answersOpen,
                        answersSingleSelect: $answersSingleSelect,
                        newGoalSaved: $newGoalSaved
                    )
                    .padding(.horizontal)
                
                case 1:
                    NewCategoryReflectionView (
                        newCategoryViewModel: newCategoryViewModel,
                        mainSelectedTab: $mainSelectedTab
                    )
                    .padding(.horizontal)
    
                default:
                    NewCategoryRevealPlanView (
                        newCategoryViewModel: newCategoryViewModel,
                        showSheet: $showNewGoalSheet
                    )
            }
        }
        .padding(.bottom)
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor: AppColors.backgroundOnboardingIntro)
        }
        .environment(\.colorScheme, .dark )
     
    }
  
    private func exitFlowAction() {
        //dismiss
        cancelledCreateNewCategory = true
        showNewGoalSheet = false
        if newGoalSaved {
            Task {
                await dataController.deleteLastGoal()
            }
        }
    }
}


struct NewCategoryHeader: View {
    @Binding var mainSelectedTab: Int
    let xmarkAction: () -> Void
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        
        HStack (spacing: 0) {
            ToolbarTitleItem2(
                emoji: mainSelectedTab > 0 ? "realm66" : "",
                title: getToolBarText()
            )
            
            Button {
                xmarkAction()
            } label: {
                
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(AppColors.progressBarPrimary.opacity(0.3))
            }
    
        }//HStack
        .frame(width: screenWidth - 32)
        .padding(.top)
        .padding(.bottom, 15)
    }
    
    private func getToolBarText() -> String {
        switch mainSelectedTab {
        case 1:
            return "Your mirror is taking it in"
            
        case 2:
            return "Your mirror reflects back"
            
        case 3, 4:
           return "Choose a direction"
            
        default:
           return ""
        }
        
    }
    
}
