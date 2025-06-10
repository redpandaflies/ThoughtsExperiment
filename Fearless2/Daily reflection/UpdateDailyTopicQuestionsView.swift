//
//  UpdateDailyTopicQuestionsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/9/25.
//

import SwiftUI

struct UpdateDailyTopicQuestionsView: View {
    
    @ObservedObject var dailyTopicViewModel: DailyTopicViewModel
    
    @Binding var selectedTabQuestions: Int
    @Binding var showProgressBar: Bool
    @Binding var selectedQuestion: Int
    @Binding var answersOpen: [String]
    @Binding var singleSelectAnswer: String
    @Binding var multiSelectAnswers: [String]
    @Binding var singleSelectCustomItems: [String]
    @Binding var multiSelectCustomItems: [String]
    
    let topic: TopicDaily
    let questions: FetchedResults<Question>
    let retryAction: () -> Void
    
    @FocusState.Binding var focusField: DefaultFocusField?
    
    let frameWidth: CGFloat = 310
    
    var body: some View {
        VStack (alignment: .leading) {
            
            switch selectedTabQuestions {
                
            case 0:
                LoadingPlaceholderContent(contentType: .newTopic)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                
            case 1:
                
                if questions.count > 0 {
                    
                    UpdateTopicQuestionsView(
                        showProgressBar: $showProgressBar,
                        selectedQuestion: $selectedQuestion,
                        answersOpen: $answersOpen,
                        singleSelectAnswer: $singleSelectAnswer,
                        multiSelectAnswers: $multiSelectAnswers,
                        singleSelectCustomItems: $singleSelectCustomItems,
                        multiSelectCustomItems: $multiSelectCustomItems,
                        focusField: $focusField,
                        topic: topic,
                        questions: questions
                    )
                    .padding(.top, 20)
                    .padding(.horizontal)
                }
            default:
                FocusAreaRetryView(action: {
                    retryAction()
                })
                .frame(width: frameWidth)
                .padding(.top, 20)
                
                
                
            }
            
        }
        .onAppear {
            if questions.isEmpty && dailyTopicViewModel.createTopicQuestions == .ready {
                retryAction()
            } else {
                manageView()
            }
        }
        .onChange(of: dailyTopicViewModel.createTopicQuestions) {
            manageView()
        }
    }
    
    private func manageView() {
        switch dailyTopicViewModel.createTopicQuestions {
        case .ready:
            // update answersOpen var
            answersOpen = Array(repeating: "", count: questions.count)
            selectedTabQuestions = 1
        case .loading:
            selectedTabQuestions = 0
        case .retry:
            selectedTabQuestions = 2
        }
        
    }
}


