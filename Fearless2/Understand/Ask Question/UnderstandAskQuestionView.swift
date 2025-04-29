////
////  UnderstandAskQuestionView.swift
////  Fearless2
////
////  Created by Yue Deng-Wu on 11/21/24.
////
//
//import SwiftUI
//
//struct UnderstandAskQuestionView: View {
//    
//    @ObservedObject var understandViewModel: UnderstandViewModel
//    
//    @State private var showCard: Bool = false
//    
//    @State private var topicText: String = ""//user's question
//    @State private var selectedUnderstand: Understand? = nil
//    @Binding var showAskQuestionView: Bool
//    @Binding var askQuestionTab: Int
//    
//    @FocusState var isFocused: Bool
//    
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .fill(Material.ultraThin)
//                .ignoresSafeArea()
//                .onTapGesture {
//                    cancelQuestion()
//                }
//            VStack {
//                VStack {
//                    switch askQuestionTab {
//                    case 0:
//                        if showCard {
//                            UnderstandAskQuestionBox(understandViewModel: understandViewModel, topicText: $topicText, isFocused: $isFocused)
//                                .padding(.horizontal)
//                                .transition(.move(edge: .bottom))
//                        }
//                        
//                    case 1:
//                        UnderstandLoadingView()
//                        
//                    default:
//                        if let understand = selectedUnderstand {
//                            UnderstandQuestionAnswer(understand: understand)
//                        }
//                        
//                    }
//                }//Group
//                .frame(height: (askQuestionTab <= 1) ? 340 : 500)
//                .background {
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(AppColors.questionBoxBackground)
//                        .shadow(color: .black.opacity(0.07), radius: 3, x: 0, y: 1)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 20)
//                                .strokeBorder(
//                                    AppColors.understandYellow.opacity(0.6),
//                                    lineWidth: 1
//                                )
//                        }
//                }
//                .padding(.bottom, 10)
//                
//                if askQuestionTab == 0 {
//                    submitButton()
//                }
//            }
//            .padding(.horizontal)
//            
//        }
//        .environment(\.colorScheme, .dark)
//        .onAppear {
//            withAnimation(.snappy(duration: 0.2)) {
//                self.showCard = true
//            }
//        }
//        .onChange(of: understandViewModel.updatedAnswer) {
//            if let newAnswer = understandViewModel.updatedAnswer {
//                //open question detail view
//                selectedUnderstand = newAnswer
//                askQuestionTab += 1
//            }
//        }
//    }
//    
//    private func cancelQuestion() {
//        withAnimation(.snappy(duration: 0.2)) {
//            self.showCard = false
//        }
//        showAskQuestionView = false
//        askQuestionTab = 0
//    }
//    
//    private func submitButton() -> some View {
//        HStack {
//            
//            Spacer()
//            
//            Button {
//                
//                let userQuestion = topicText
//                isFocused = false
//                askQuestionTab += 1
//                topicText = ""
//                
//                Task {
//                    await understandViewModel.manageRun(selectedAssistant: .understand, question: userQuestion)
//                }
//                
//              
//            } label: {
//                Image(systemName: "arrow.right.circle.fill")
//                    .font(.system(size: 30, weight: .light))
//                    .foregroundStyle(AppColors.whiteDefault)
//            }
//            
//            
//        }
//    }
//}
//
////#Preview {
////    UnderstandAskQuestionView()
////}
