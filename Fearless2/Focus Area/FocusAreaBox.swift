//
//  FocusAreaBox.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/8/24.
//
import Pow
import SwiftUI


struct FocusAreaBox: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTab: Int = 0
    
    @Binding var showFocusAreaRecapView: Bool
    @Binding var selectedSection: Section?
    @Binding var selectedSectionSummary: SectionSummary?
    @Binding var selectedFocusArea: FocusArea?
    @ObservedObject var focusArea: FocusArea
    let index: Int
    
    var body: some View {
       
        VStack (spacing: 10){
            Group {
                
                Text("\(index + 1)")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 40, weight: .thin))
                    .fontWidth(.expanded)
                    .foregroundStyle(AppColors.whiteDefault)
                
                Text(focusArea.focusAreaTitle)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 25, weight: .light))
                    .fontWeight(.regular)
                    .foregroundStyle(AppColors.whiteDefault)
                    .fixedSize(horizontal: false, vertical: true)
                
                
                Text(focusArea.focusAreaReasoning)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 16, weight: .light))
                    .fontWidth(.condensed)
                    .fontWeight(.regular)
                    .foregroundStyle(AppColors.whiteDefault)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(0.5)
                    .padding(.bottom, 10)
            }
            .padding(.horizontal)
            
           
            switch selectedTab {
                case 0:
                    LoadingPlaceholderContent(contentType: .focusArea)
                
                default:
                    SectionListView(showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, focusArea: focusArea, focusAreaCompleted: focusArea.completed)
                
            }


         
            
            Spacer()
            
        }//VStack
        .onAppear {
            if !focusArea.focusAreaSections.isEmpty {
                selectedTab = 1
            }
        }
        .onChange(of: topicViewModel.focusAreaUpdated) {
            if topicViewModel.focusAreaUpdated {
                selectedTab += 1
            }
        }
        
    }
}

//#Preview {
//    FocusAreaBox()
//}
