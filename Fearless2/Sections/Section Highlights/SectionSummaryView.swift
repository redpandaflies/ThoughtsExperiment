//
//  SectionSummaryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/29/24.
//

import SwiftUI

struct SectionSummaryView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var summary: SectionSummary
    @Binding var showCreateNewTopicView: Bool?
    @Binding var showUpdateTopicView: Bool?
    
    let isFullScreen: Bool
    let selectedCategory: TopicCategoryItem
    
    init(summary: SectionSummary, showCreateNewTopicView: Binding<Bool?> = .constant(nil), showUpdateTopicView: Binding<Bool?> = .constant(nil), isFullScreen: Bool = false, selectedCategory: TopicCategoryItem) {
        self.summary = summary
        self._showCreateNewTopicView = showCreateNewTopicView
        self._showUpdateTopicView = showUpdateTopicView
        self.isFullScreen = isFullScreen
        self.selectedCategory = selectedCategory
        
    }
    
    var body: some View {
        
        VStack {
            VStack (alignment: .leading) {
                
                Text(summary.section?.sectionTitle ?? "")
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(selectedCategory.getCategoryColor())
                    .textCase(.uppercase)
                    .padding(.bottom, 5)
                
                ScrollView {
                    VStack (alignment: .leading, spacing: 15) {
                        ForEach(summary.summaryInsights, id: \.insightId) { insight in
                            
                            SectionInsightBoxView(insight: insight)
                        }
                    }
                }//Scrollview
                .scrollIndicators(.hidden)

            }//VStack
            .padding()
            .padding(.top)
            .frame(height: 460)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.questionBoxBackground)
                    .shadow(color: .black.opacity(0.07), radius: 3, x: 0, y: 1)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                AngularGradient(gradient: Gradient(colors: [.red, .purple, .blue, .purple, .yellow, .red]), center: .center, startAngle: .zero, endAngle: .degrees(360)),
                                lineWidth: 1
                            )
                    }
            }
            
            RectangleButton(buttonName: "Done", buttonColor: Color.white.opacity(0.6))
                .onTapGesture {
                    closeView()
                }
                .sensoryFeedback(.selection, trigger: showCreateNewTopicView) { oldValue, newValue in
                    return oldValue != newValue && newValue == true
                }
            
            
        }
    }
    
    private func closeView() {
        withAnimation(.snappy(duration: 0.2)) {
            showUpdateTopicView = false
            if let section = summary.section {
                Task {
                    section.completed = true
                    await dataController.save()
                }
            }
        }
    }
}


