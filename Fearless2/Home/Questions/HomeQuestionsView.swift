//
//  HomeQuestionsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import SwiftUI

struct HomeQuestionsView: View {
    @Binding var showUpdateTopicView: Bool
    @Binding var topicId: UUID?
    @Binding var selectedQuestion: String
    let questions: [Question]
    
    var body: some View {
        VStack (alignment: .leading, spacing: 8){
            Text("Questions for you")
                .multilineTextAlignment(.leading)
                .font(.system(size: 14))
                .fontWeight(.medium)
            
            ForEach(questions, id: \.questionId) { question in
                HomeQuestionBox(questionEmoji: question.questionEmoji, questionText: question.questionContent)
                    .onTapGesture {
                        guard let selectedTopicId = question.questionTopic?.topicId else {return}
                        topicId = selectedTopicId
                        selectedQuestion = question.questionContent
                        showUpdateTopicView =  true
                    }
                    .padding(.bottom, 3)
            }
        }
    }
}

//#Preview {
//    HomeQuestionsView()
//}
