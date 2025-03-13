//
//  FocusAreaView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/3/24.
//
import CoreData
import SwiftUI

struct FocusAreasView: View {
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var selectedTab: Int = 1
    
    @Binding var showFocusAreaRecapView: Bool
    @Binding var selectedSection: Section?
    @Binding var selectedSectionSummary: SectionSummary?
    @Binding var selectedFocusArea: FocusArea?
    @Binding var selectedEndOfTopicSection: Section?
    @Binding var focusAreaScrollPosition: Int?
    
    let topicId: UUID
  
    let screenHeight = UIScreen.current.bounds.height
    
    @FetchRequest var focusAreas: FetchedResults<FocusArea>
    
    init(topicViewModel: TopicViewModel, showFocusAreaRecapView: Binding<Bool>, selectedSection: Binding<Section?>, selectedSectionSummary: Binding<SectionSummary?>, selectedFocusArea: Binding<FocusArea?>, focusAreaScrollPosition: Binding<Int?>, selectedEndOfTopicSection: Binding<Section?>, topicId: UUID) {
        self.topicViewModel = topicViewModel
        self._showFocusAreaRecapView = showFocusAreaRecapView
        self._selectedSection = selectedSection
        self._selectedSectionSummary = selectedSectionSummary
        self._selectedFocusArea = selectedFocusArea
        self._selectedEndOfTopicSection = selectedEndOfTopicSection
        self._focusAreaScrollPosition = focusAreaScrollPosition
        self.topicId = topicId
        
        let request: NSFetchRequest<FocusArea> = FocusArea.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        request.predicate = NSPredicate(format: "topic.id == %@", topicId as CVarArg)
        
        self._focusAreas = FetchRequest(fetchRequest: request)
        
    }
    
    var body: some View {
        
        VStack {
            switch selectedTab {
                case 0:
                    FocusAreaEmptyState(topicViewModel: topicViewModel, selectedTab: $selectedTab, topicId: topicId)
                default:
                    FocusAreaList(topicViewModel: topicViewModel, showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, selectedEndOfTopicSection: $selectedEndOfTopicSection, focusAreaScrollPosition: $focusAreaScrollPosition, focusAreas: focusAreas)
            }
        }
        .ignoresSafeArea(.keyboard)
        .overlay {
            if let scrollPosition = focusAreaScrollPosition {
                nextFocusAreaIndicator(scrollPosition: scrollPosition)
            }
        }
        .onAppear {
            if !focusAreas.isEmpty && selectedTab != 1 {
                selectedTab = 1
            }
        }
    }
    
    private func nextFocusAreaIndicator(scrollPosition: Int) -> some View {
        VStack {
            Spacer()

            if scrollPosition < focusAreas.count - 1 {
                VStack (spacing: 10){
                    Text(getNextFocusAreaTitle(scrollPosition: scrollPosition))
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                        .onAppear {
                            print("Scroll position: \(scrollPosition), total focus area \(focusAreas.count)")
                        }
                    
                    Image(systemName: "chevron.compact.down")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                }
                .padding()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        focusAreaScrollPosition = scrollPosition + 1
                    }
                }
            }
        }
        
    }
    
    private func getNextFocusAreaTitle(scrollPosition: Int) -> String {
     
        let totalFocusAreas = focusAreas.count
        if scrollPosition < totalFocusAreas - 1 {
            let nextFocusAreaIndex = scrollPosition + 1
            let nextFocusArea = focusAreas[nextFocusAreaIndex]
            let nextFocusAreaDisplayNumber = scrollPosition + 2 //the number displayed for focus area in UI
            
            if let topic = focusAreas.first?.topic {
                let limit = Int(topic.focusAreasLimit)
                if scrollPosition == limit - 1 {
                    return "\(nextFocusArea.focusAreaTitle)"
                }
            }
            
            return "\(nextFocusAreaDisplayNumber) \(nextFocusArea.focusAreaTitle)"
        } else {
            return ""
        }
        
    }
    
}


struct FocusAreaList: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var scrollViewHeight: CGFloat = 0
   
    @Binding var showFocusAreaRecapView: Bool
    @Binding var selectedSection: Section?
    @Binding var selectedSectionSummary: SectionSummary?
    @Binding var selectedFocusArea: FocusArea?
    @Binding var selectedEndOfTopicSection: Section?
    @Binding var focusAreaScrollPosition: Int?
       
    let focusAreas: FetchedResults<FocusArea>
    let screenHeight = UIScreen.current.bounds.height
    var filteredFocusAreas: [FocusArea] {
        return focusAreas.filter {$0.endOfTopic != true}
    }
    var endOfTopicFocusArea: FocusArea? {
        let staticFocusArea = focusAreas.filter {$0.endOfTopic == true}
        return staticFocusArea.first
    }
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            VStack (alignment: .leading) {
                ForEach(Array(filteredFocusAreas.enumerated()), id: \.element.focusAreaId) { index, area in
                    
                    FocusAreaBox(topicViewModel: topicViewModel, showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, selectedEndOfTopicSection: $selectedEndOfTopicSection, focusArea: area, index: index)
                        .id(index)
                        .containerRelativeFrame(.vertical, alignment: .top)
                        .scrollTransition { content, phase in
                            content
                            .opacity(phase.isIdentity ? 1 : 0)
                            .scaleEffect(phase.isIdentity ? 1 : 0.8)
                            .blur(radius: phase.isIdentity ? 0 : 30)
                        }
                    
                }//ForEach
                
                //end of topic
                if let endOfTopic = endOfTopicFocusArea {
                    FocusAreaBox(topicViewModel: topicViewModel, showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, selectedEndOfTopicSection: $selectedEndOfTopicSection, focusArea: endOfTopic, index: filteredFocusAreas.count)
                        .id(filteredFocusAreas.count)
                        .containerRelativeFrame(.vertical, alignment: .top)
                        .scrollTransition { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.8)
                                .blur(radius: phase.isIdentity ? 0 : 30)
                        }
                }
                
                
            }//VStack
            .scrollTargetLayout()
            
        }//ScrollView
        .frame(height: screenHeight * 0.6)
        .scrollPosition(id: $focusAreaScrollPosition)
        .scrollTargetBehavior(.paging)
        .scrollBounceBehavior(.basedOnSize)
        .scrollClipDisabled(true)
        .contentMargins(.vertical, 10, for: .scrollContent)
        .onChange(of: dataController.newFocusArea) {
            focusAreaScrollPosition = dataController.newFocusArea
        }
        .onChange(of: focusAreaScrollPosition) {
            print("Scroll position updated to: \(focusAreaScrollPosition ?? -1)")
        }
        .onAppear {
            let totalFocusArea = focusAreas.count
            print("total focus area for this topic: \(totalFocusArea)")
            let scrollPosition = totalFocusArea - 1
            if scrollPosition >= 0 {
                focusAreaScrollPosition = scrollPosition
                print("set focus area scroll position: \(scrollPosition)")
            } else {
                focusAreaScrollPosition = 0
            }
        }
        .onDisappear {
            focusAreaScrollPosition = nil
        }
    }
}


//#Preview {
//    FocusAreaView()
//}
