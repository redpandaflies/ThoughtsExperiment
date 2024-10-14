//
//  UpdateTopicBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//

import SwiftUI

struct UpdateTopicBox: View {
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var topicText = ""
    @Binding var showCard: Bool
    @Binding var selectedTab: Int
    @FocusState var isFocused: Bool
    
    let selectedCategory: CategoryItem
    let topicId: UUID?
    let question: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 12) {
            HStack {
                BubblesCategory(selectedCategory: selectedCategory, useFullName: true)
                
                Spacer()
            }
            
            Text(selectedCategory.getDescription())
                .multilineTextAlignment(.leading)
                .font(.system(size: 13))
                .fontWeight(.regular)
                .foregroundStyle(AppColors.blackDefault)
                .padding(.bottom, 10)
            
            Text(question)
                .multilineTextAlignment(.leading)
                .font(.system(size: 19))
                .fontWeight(.medium)
                .foregroundStyle(AppColors.blackDefault)
            
            
            ScrollView {
                HStack (alignment: .top) {
                    
                    Rectangle()
                        .fill(selectedCategory.getBubbleColor())
                        .cornerRadius(30)
                        .frame(width: 3)
                    
                    
                    Group {
                        TextField("Enter your answer", text: $topicText, axis: .vertical)
                            .font(.system(size: 16))
                            .fontWeight(.light)
                            .foregroundStyle(AppColors.blackDefault)
                            .opacity(0.7)
                            .lineSpacing(3)
                            .focused($isFocused)
                            .keyboardType(.alphabet)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isFocused = true
                    }
                    
                }//HStack
                .padding(.horizontal, 5)
            }
            .scrollIndicators(.hidden)
            .frame(maxHeight: 130)
            .padding(.bottom)
            
            HStack {
                Spacer()
                
                Button {
                    Task {
                        await submitForm()
                    }
                    
                } label: {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(AppColors.blackDefault)
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.07), radius: 3, x: 0, y: 1)
              
        }
    }
    
    func submitForm() async {
        isFocused = false
        
        withAnimation(.snappy(duration: 0.2)) {
            self.showCard = false
        }
        selectedTab += 1
        
        await topicViewModel.manageRun(selectedAssistant: .topic, category: selectedCategory, userInput: topicText, topicId: topicId, question: question)
    }
    
}

//#Preview {
//    UpdateTopicBox()
//}
