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
    @State private var disableButton: Bool = true
    
    @Binding var showTopicExpecationsSheet: Bool
    
    let topic: Topic?
    let goal: String
    let expectations: [TopicExpectation]
    let backgroundColor: Color
    
    let screenWidth = UIScreen.current.bounds.width
    
    var sortedExpectations: [TopicExpectation] {
        return expectations.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 10) {
            
            getHeader(xmarkAction: {
                //dismiss
                showTopicExpecationsSheet = false
            })
            .padding(.bottom)
            
            Text("What to expect")
                .multilineTextAlignment(.leading)
                .font(.system(size: 25, design: .serif))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom)
            
            CarouselView(items: sortedExpectations, scrollPosition: $expectationsScrollPosition, pagesCount: sortedExpectations.count) { index, expectation in
                CarouselBox(orderIndex: index + 1, content: expectation.expectationContent)
            }
            
            Spacer()
            
            // MARK: Next button
            RectangleButtonPrimary(
                buttonText: "Continue",
                action: {
                    completeQuest()
                },
                disableMainButton: disableButton,
                buttonColor: .white)
            
        }//VStack
        .padding(.bottom)
        .padding(.horizontal)
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            BackgroundPrimary(backgroundColor: backgroundColor)
        }
        .environment(\.colorScheme, .dark )
        .onAppear {
            if topic?.topicStatus == TopicStatusItem.completed.rawValue {
                disableButton = false
            }
        }
        .onChange(of: expectationsScrollPosition) {
            if (expectationsScrollPosition == sortedExpectations.count - 1) && (topic?.topicStatus != TopicStatusItem.completed.rawValue) {
                if disableButton {
                    disableButton = false
                }
            }
        }
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
        .frame(maxWidth: .infinity)
        .padding(.top)
        .padding(.bottom, 15)
        
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


