//
//  UpdateSectionView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//
import CoreData
import SwiftUI

struct UpdateSectionView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    
    @State private var topicText = ""
    @State private var showCard: Bool = false
    @State private var selectedTab: Int = 0
    @State private var showWarningSheet: Bool = false
    
    @Binding var showUpdateSectionView: Bool?
    @Binding var selectedSectionSummary: SectionSummary?
    
    let topicId: UUID?
    let section: Section?
    
    
    init(topicViewModel: TopicViewModel, showUpdateSectionView: Binding<Bool?> = .constant(nil), selectedSectionSummary: Binding<SectionSummary?>, topicId: UUID?, section: Section?) {
        self.topicViewModel = topicViewModel
        self._showUpdateSectionView = showUpdateSectionView
        self._selectedSectionSummary = selectedSectionSummary
        self.topicId = topicId
        self.section = section
    }
    
    var body: some View {
        
        ZStack {
            
            Rectangle()
                .fill(Material.ultraThin)
                .ignoresSafeArea()
                .onTapGesture {
                    closeView()
                }
                
            switch selectedTab {
            case 0:
                if showCard {
                    
                    if let sectionQuestions = section?.sectionQuestions {
                        UpdateSectionBox(topicViewModel: topicViewModel, showCard: $showCard, selectedTab: $selectedTab, section: section, questions: sectionQuestions)
                            .padding(.horizontal)
                            .transition(.move(edge: .bottom))
                    }
                }
            default:
                LoadingAnimation()
                
            }//switch
                
        }//ZStack
        .environment(\.colorScheme, .dark)
        .onAppear {
            withAnimation(.snappy(duration: 0.2)) {
                self.showCard = true
            }
        }
        .onChange(of: topicViewModel.sectionSummaryCreated) {
            if topicViewModel.sectionSummaryCreated {
               closeView()
                
                if let summary = section?.summary {
                    selectedSectionSummary = summary
                }
            }
        }
        .sheet(isPresented: $showWarningSheet, onDismiss: {
            showWarningSheet = false
        }) {
            WarningLostProgress(quitAction: {
                closeView()
            })
            .presentationCornerRadius(20)
            .presentationBackground(AppColors.black3)
            .presentationDetents([.medium])
        }
    }
    
    private func closeView() {
        withAnimation(.snappy(duration: 0.2)) {
            self.showCard = false
        }
        showUpdateSectionView = false
    }
}

//#Preview {
//    UpdateSectionView()
//}
