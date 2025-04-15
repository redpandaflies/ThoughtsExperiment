//
//  TopicExpectationsView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/14/25.
//

import SwiftUI

struct TopicExpectationsView: View {
    @EnvironmentObject var dataController: DataController
    
    @State private var expectationsScrollPosition: Int?
    
    @Binding var showTopicExpecationsSheet: Bool
    
    let topic: Topic?
    let goal: String
    let expectations: [TopicExpectation]
    let backgroundColor: Color
    
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 10) {
            
            getHeader(xmarkAction: {
                //dismiss
                showTopicExpecationsSheet = false
            })
            
            Text("What to expect")
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            getContent()
            
            Spacer()
            
            // MARK: Next button
            RectangleButtonPrimary(
                buttonText: "Continue",
                action: {
                    completeQuest()
                },
                buttonColor: .white)
            
        }//VStack
        .padding(.bottom)
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor: backgroundColor)
        }
        .environment(\.colorScheme, .dark )
    }
    
    
    private func getHeader(xmarkAction: @escaping () -> Void) -> some View {
        HStack (spacing: 0) {
            ToolbarTitleItem2(
                emoji: "",
                title: goal
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
    
    private func getContent() -> some View {
        VStack (alignment: .leading, spacing: 15) {
            ScrollView (.horizontal) {
                HStack (alignment: .center, spacing: 15) {
                    ForEach(Array(expectations.enumerated()), id: \.element.expectationId) { index, expectation in
                        TopicExpectationBox(expectation: expectation)
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $expectationsScrollPosition, anchor: .leading)
            .scrollClipDisabled(true)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
            .scrollIndicators(.hidden)
            
            PageIndicatorView(scrollPosition: $expectationsScrollPosition, pagesCount: expectations.count)
            
        }
    }
    
    private func completeQuest() {
        Task {
            if let topic = topic {
                await dataController.completeTopic(topic: topic)
            }
            await MainActor.run {
                showTopicExpecationsSheet = false
            }
        }
    }
}


struct TopicExpectationBox: View {
    
    let expectation: TopicExpectation
    
    var body: some View {
        VStack {
            Text("\(Int(expectation.orderIndex))")
                .multilineTextAlignment(.leading)
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                .opacity(0.5)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 20)
             
            
            Text(expectation.expectationContent)
                .multilineTextAlignment(.leading)
                .font(.system(size: 20, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(1.4)
                .fixedSize(horizontal: false, vertical: true)
                
               
        }
        .padding(.horizontal)
        .frame(width: 300, height: 420, alignment: .top)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .stroke(AppColors.textSecondary.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.boxGrey1.opacity(0.3))
                .blendMode(.colorDodge)
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 3)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
