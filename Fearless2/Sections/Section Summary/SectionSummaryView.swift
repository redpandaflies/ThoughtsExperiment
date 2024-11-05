//
//  SectionSummaryView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/29/24.
//

import SwiftUI

struct SectionSummaryView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var entry: Entry
    @Binding var showCreateNewTopicView: Bool?
    @Binding var showUpdateTopicView: Bool?
    
    let isFullScreen: Bool
    
    init(entry: Entry, showCreateNewTopicView: Binding<Bool?> = .constant(nil), showUpdateTopicView: Binding<Bool?> = .constant(nil), isFullScreen: Bool = false) {
        self.entry = entry
        self._showCreateNewTopicView = showCreateNewTopicView
        self._showUpdateTopicView = showUpdateTopicView
        self.isFullScreen = isFullScreen
        
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    ZStack {
                        UnevenRoundedRectangle(cornerRadii: .init(
                            topLeading: 0,
                            bottomLeading: 20,
                            bottomTrailing: 20,
                            topTrailing: 0), style: .continuous)
                        .fill(AppColors.sectionSummaryLight)
                        .blendMode(.softLight)
                        .shadow(color: .black.opacity(0.1), radius: 2.5, x: 0, y: 2)
                        .padding(.top, 0)
                        
                        VStack (alignment: .leading, spacing: 10){
                            
                            Text(entry.section?.sectionTitle ?? "")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.blackDefault)
                                .padding(.bottom, 10)
                            
                            Text(entry.entrySummary)
                                .font(.headline)
                                .fontWeight(.regular)
                                .foregroundColor(AppColors.blackDefault)
                                .padding(.bottom, 10)
                            
                            ForEach(entry.entryInsights, id: \.insightId) { insight in
                                
                                InsightBoxView(insight: insight)
                                    .padding(.bottom, 5)
                            }
                            
                            
                        }//VStack
                        .padding()
                        .padding(.top, isFullScreen ? 90 : 50)
                        
                    }//ZStack
                    .padding(.bottom, 40)
                    
                    Image("cloudWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
                        .padding(.bottom, 7)
                    
                    if !entry.entryFeedback.isEmpty {
                        Text(entry.entryFeedback)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color.white)
                            .font(.headline)
                            .fontWeight(.regular)
                            .padding(.horizontal, 50)
                            .padding(.vertical)
                            .background {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.clear)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    .padding(.horizontal, 35)
                            }
                            .padding(.bottom, 25)
                    }
                    
                    VStack (alignment: .leading, spacing: 10) {
                        Text("Questions Answered")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.white)
                        
                        if let questions = entry.section?.sectionQuestions {
                            ForEach(questions, id: \.questionId) { question in
                                if question.completed {
                                    EntryQuestionView(question: question)
                                }
                            }
                        }
                       
                    }//VStack
                    .padding(.horizontal, 50)
                    .padding(.bottom, 40)
                }//VStack
            }//Scrollview
            .ignoresSafeArea()
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .background {
                AppColors.sectionSummaryDark
                    .ignoresSafeArea()
            }
            .navigationTitle("Entry")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        
                        
                       
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.black)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .customToolbarAppearance()
        }
    }
    
    private func closeView() {
        if let showingNewTopicView = showCreateNewTopicView, showingNewTopicView {
            withAnimation(.snappy(duration: 0.2)) {
                showCreateNewTopicView = false
            }
        } else {
            withAnimation(.snappy(duration: 0.2)) {
                showUpdateTopicView = false
                if let section = entry.section {
                    Task {
                        section.completed = true
                        await dataController.save()
                    }
                }
            }
        }
    }
}


