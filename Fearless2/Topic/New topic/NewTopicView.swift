//
//  NewTopicView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/1/24.
//
import Mixpanel
import OSLog
import SwiftUI

struct NewTopicView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var selectedQuestion: Int = 0
    @State private var topicText: String = ""//user's definition of the new topic
    @State private var answer1: String = ""//user's answer to the first question
    @State private var answer2: String = ""//user's answer to the second question
    @State private var singleSelectAnswer: String = "" //single-select answer
    @State private var multiSelectAnswers: [String] = [] //answers user choose for muti-select questions
    @State private var activeIndex: Int? = nil //controls the state of the loading view
    @State private var animationValue: Bool = false //controls animation of the ellipsis on loading view
    @FocusState var isFocused: Bool
    
    @Binding var selectedTopic: Topic?
    @Binding var navigateToTopicDetailView: Bool
    @Binding var currentTabBar: TabBarType
    @Binding var focusAreasLimit: Int
    
    let category: Category
    
    let logger = Logger.openAIEvents
    let screenHeight = UIScreen.current.bounds.height
    
    var body: some View {
        VStack {
            
            NewTopicHeader(xmarkAction: {
                cancelRun()
            })
            .padding(.horizontal)
           
            TopicSuggestionsList(topicViewModel: topicViewModel, selectedTopic: $selectedTopic, navigateToTopicDetailView: $navigateToTopicDetailView, currentTabBar: $currentTabBar, focusAreasLimit: $focusAreasLimit, category: category)
            
                        
        }
        .backgroundSecondary(forCategory: category.categoryName, height: screenHeight * 0.65, yOffset: -(screenHeight * 0.35))
        
    }
    
    private func cancelRun() {
        dismiss()
        
        Task {
            do {
                try await topicViewModel.cancelCurrentRun()
            } catch {
                logger.error("Failed to cancel current run: \(error.localizedDescription)")
            }
        }
       
    }
    
    
}


struct NewTopicReadyView: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 15){
            Spacer()
            
            HStack {
                Text("Ready to go.")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(AppColors.whiteDefault)
                
                Spacer()
            }
            
            Text("Explore your new topic by\nchoosing a starting path.")
                .multilineTextAlignment(.leading)
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(AppColors.whiteDefault)
            
            Spacer()
        }
        .padding(.bottom, 40)
    }
}

struct NewTopicRetryView: View {
    
    let retryAction: () -> Void
    
    var body: some View {
        VStack (alignment: .leading, spacing: 15){
            Spacer()
            
            RetryButton(action: {
                retryAction()
            })
            
            Spacer()
        }
        .padding(.bottom, 40)
    }
}


//#Preview {
//    CreateNewTopicView(selectedCategory: .decision)
//}
