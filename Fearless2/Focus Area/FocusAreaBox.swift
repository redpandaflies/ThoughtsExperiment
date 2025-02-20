//
//  FocusAreaBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/8/24.
//
import OSLog
import Pow
import SwiftUI




struct FocusAreaBox: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTab: Int = 0
    
    @Binding var showFocusAreaRecapView: Bool
    @Binding var selectedSection: Section?
    @Binding var selectedSectionSummary: SectionSummary?
    @Binding var selectedFocusArea: FocusArea?
    @Binding var selectedEndOfTopicSection: Section?
    @ObservedObject var focusArea: FocusArea
    let index: Int
   
    
    let logger = Logger.openAIEvents
    
    var body: some View {
       
        VStack (spacing: 10){
            Group {
                
                if focusArea.endOfTopic != true {
                    Text("\(index + 1)")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 40, weight: .thin))
                        .fontWidth(.expanded)
                        .foregroundStyle(AppColors.textPrimary)
                } else {
                    getLaurels()
                }
                
                Text(focusArea.focusAreaTitle)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25, weight: .light))
                    .fontWeight(.regular)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                
                
                Text(focusArea.focusAreaReasoning)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .light))
                    .fontWidth(.condensed)
                    .fontWeight(.regular)
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(0.5)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal)
            
           
            switch selectedTab {
                case 0:
                    LoadingPlaceholderContent(contentType: .focusArea)
                
                case 1:
                SectionListView(topicViewModel: topicViewModel, showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, selectedEndOfTopicSection: $selectedEndOfTopicSection, focusArea: focusArea, focusAreaCompleted: focusArea.completed)
                
                default:
                    FocusAreaRetryView(action: {
                        retry()
                    })
                
            }
            
            Spacer()
            
        }//VStack
        .onAppear {
            if focusArea.focusAreaSections.isEmpty && !topicViewModel.updatingfocusArea {
                selectedTab = 2
            } else if topicViewModel.updatingfocusArea {
                selectedTab = 0
            } else {
                selectedTab = 1
            }
        }
        .onChange(of: topicViewModel.focusAreaUpdated) {
            //focusArea.completed needed so that only the completed ones aren't affected
            if topicViewModel.focusAreaUpdated && !focusArea.completed {
                selectedTab += 1
            }
        }
        .onChange(of: topicViewModel.focusAreaCreationFailed) {
            //focusArea.completed needed so that only the completed ones aren't affected
            if topicViewModel.focusAreaCreationFailed && !focusArea.completed {
                selectedTab = 2
            }
        }
                
        
    }
    
    private func retry() {
        selectedTab = 0
        
        Task {
            do {
                //API call to create new focus area
               try await topicViewModel.manageRun(selectedAssistant: .focusArea, topicId: focusArea.topic?.topicId, focusArea: focusArea)
                
            } catch {
                logger.error("Failed to complete OpenAI run, showing option to retry")
                await MainActor.run {
                    selectedTab = 2
                }
            }
        }
    }
    
    private func getLaurels() -> some View {
        HStack (spacing: 5){
            Image(systemName: "laurel.leading")
                .font(.system(size: 40, weight: .thin))
                .foregroundStyle(AppColors.textPrimary)
            
            
            Image(systemName: "laurel.trailing")
                .font(.system(size: 40, weight: .thin))
                .foregroundStyle(AppColors.textPrimary)
        }
    }
    
}



//#Preview {
//    FocusAreaBox()
//}
