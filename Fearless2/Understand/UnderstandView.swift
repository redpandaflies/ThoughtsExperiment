//
//  UnderstandView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/20/24.
//

import SwiftUI

struct UnderstandView:View {
    
    @ObservedObject var understandViewModel: UnderstandViewModel
    @State private var showUnderstandQuestionsList: Bool = false
    @Binding var showAskQuestionView: Bool
    @Binding var askQuestionTab: Int
    
    let screenWidth = UIScreen.current.bounds.width
    
    let options: [[String]] = [
        ["values", "behavioral patterns", "motivators"],
        ["strengths and unique skills", "growth areas"],
        ["progress", "recommended actions"]
    ]
    
    var body: some View {
        
        NavigationStack {
            VStack (spacing: 5){
                Text("Understand")
                    .font(.system(size: 30))
                    .foregroundStyle(AppColors.understandYellow)
                    .padding(.top, 250)
                
                Text("Yourself")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColors.understandYellow)
                    .textCase(.uppercase)
                    .padding(.bottom, 20)
                
                ForEach(options, id: \.self) { chunk in
                    HStack (spacing: 10) {
                        ForEach(chunk, id: \.self) { option in
                            questionBox(option)
                                .onTapGesture {
                                    askDefaultQuestion(option)
                                }
                            
                        }
                    }
                    .padding(.bottom, 5)
                }
                
                Spacer()
                
                RectangleButton(buttonName: "Ask a question about yourself", buttonColor: AppColors.understandWhite)
                    .padding()
                    .onTapGesture {
                        askQuestionTab = 0
                        withAnimation(.snappy(duration: 0.2)) {
                            showAskQuestionView = true
                        }
                    }
                
            }//VStack
            .padding(.bottom, 90)
            .background {
                VStack {
                    Image("understand")
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth)
                    
                    Spacer()
                }
                .ignoresSafeArea(.all)
            }
            .sheet(isPresented: $showUnderstandQuestionsList, onDismiss: {
                showUnderstandQuestionsList = false
            }) {
                UnderstandQuestionsList()
                    .presentationCornerRadius(20)
                    .presentationBackground(Color.black)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    UnderstandToolbarItem(action: {
                        showUnderstandQuestionsList = true
                    })
                }
                
//                ToolbarItem(placement: .topBarTrailing) {
//                    ProfileToolbarItem()
//                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }//NavigationStack
        .environment(\.colorScheme, .dark)
    }
    
    private func questionBox(_ question: String) -> some View {
        Group {
            Text(question)
                .font(.system(size: 11))
                .foregroundStyle(AppColors.understandWhite)
                .textCase(.uppercase)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.understandWhite)
        }
    }
    
    private func askDefaultQuestion(_ question: String) {
        askQuestionTab = 1
        showAskQuestionView = true
        Task {
            let fullQuestion = "What are my \(question)?"
            await understandViewModel.manageRun(selectedAssistant: .understand, question: fullQuestion)
        }
    }
}

//#Preview {
//    UnderstandView()
//}
