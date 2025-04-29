////
////  UnderstandAskQuestionBox.swift
////  Fearless2
////
////  Created by Yue Deng-Wu on 11/21/24.
////
//
//import SwiftUI
//
//struct UnderstandAskQuestionBox: View {
//    @ObservedObject var understandViewModel: UnderstandViewModel
//    
//    @Binding var topicText: String
//   
//    @FocusState.Binding var isFocused: Bool
//    let question = "Ask a question about yourself"
//    
//    var body: some View {
//       
//        VStack (alignment: .leading, spacing: 5) {
//       
//            QuestionOpenView(topicText: $topicText, isFocused: $isFocused, question: question)
//            
//            Spacer()
//            
//        }//VStack
//        .padding()
//        .padding(.top)
//        
//    }
//    
//   
//    
//}
////
////#Preview {
////    UnderstandAskQuestionView()
////}
