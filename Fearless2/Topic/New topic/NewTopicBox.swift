//
//  NewTopicBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//

import SwiftUI

struct NewTopicBox: View {

    @Binding var selectedQuestion: Int
    @Binding var topicText: String
    @Binding var singleSelectAnswer: String
    @Binding var multiSelectAnswers: [String]
    
    @FocusState.Binding var isFocused: Bool

    var body: some View {
       
        VStack (alignment: .leading, spacing: 5) {
       
            QuestionOpenView(topicText: $topicText, isFocused: $isFocused, question: QuestionsNewTopic.questions[selectedQuestion].content, placeholderText: getPlaceholderText())
            
            Spacer()
            
        }//VStack
       
    }
    
    private func getPlaceholderText() -> String {
        if selectedQuestion == 0 {
            return "The more details the better"
        } else {
            return "I'd feel good about this if..."
        }
    }
   
}


//#Preview {
//    CreateNewTopicBox()
//}
