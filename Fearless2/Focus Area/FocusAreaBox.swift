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
                        .foregroundStyle(AppColors.textPrimary)
                } else {
                    getLaurels()
                }
                
                Text(focusArea.focusAreaTitle)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25, weight: .light))
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                
                
                Text(focusArea.focusAreaReasoning)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 17, weight: .light))
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
                    SectionListView(topicViewModel: topicViewModel, showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, selectedEndOfTopicSection: $selectedEndOfTopicSection, focusArea: focusArea, focusAreaCompleted: focusArea.focusAreaStatus == FocusAreaStatusItem.completed.rawValue)
                
                case 2:
                    SectionListLockedView()
                    
                default:
                    FocusAreaRetryView(action: {
                        retry()
                    })
                
            }
            
            Spacer()
            
        }//VStack
        .onAppear {
            let focusAreaStatus = FocusAreaStatusItem(rawValue: focusArea.focusAreaStatus)
            
            switch focusAreaStatus {
                case .active:
                    if topicViewModel.createNewFocusArea == .loading {
                        selectedTab = 0
                    } else if topicViewModel.createNewFocusArea == .retry {
                        selectedTab = 3
                    } else {
                        //in the event createNewFoucsArea is not yet == .loading, but a new focuus area is being created
                       let sections = focusArea.focusAreaSections
                        
                        if sections.count > 0 {
                            selectedTab = 1
                        } else {
                            selectedTab = 0
                        }
                    }
                case .completed:
                    selectedTab = 1
                default:
                    selectedTab = 2
                
            }
            
        }
        .onChange(of: topicViewModel.createNewFocusArea) {
            
            let focusAreaStatus = FocusAreaStatusItem(rawValue: focusArea.focusAreaStatus)
            
            if focusAreaStatus == .active {
                
                switch topicViewModel.createNewFocusArea {
                    case .retry:
                        selectedTab = 3
                    case .ready:
                        selectedTab = 1
                    case .loading:
                        selectedTab = 0
                }
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
        HStack (spacing: 15){
            Image(systemName: "laurel.leading")
                .font(.system(size: 40, weight: .thin))
                .foregroundStyle(AppColors.textPrimary)
            
            
            Image(systemName: "laurel.trailing")
                .font(.system(size: 40, weight: .thin))
                .foregroundStyle(AppColors.textPrimary)
        }
    }
    
}

struct SectionListLockedView: View {
    var body: some View {
        
        VStack {
            Image(systemName: "lock.fill")
                .multilineTextAlignment(.center)
                .font(.system(size: 30))
                .foregroundStyle(AppColors.textPrimary)
                .opacity(0.5)
                .padding(.vertical)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}



//#Preview {
//    FocusAreaBox()
//}
