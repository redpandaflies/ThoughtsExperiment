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
        request.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        request.predicate = NSPredicate(format: "topic.id == %@", topicId as CVarArg)
        
        self._focusAreas = FetchRequest(fetchRequest: request)
        
    }
    
    var body: some View {
        
        VStack {
           
            FocusAreaList(topicViewModel: topicViewModel, showFocusAreaRecapView: $showFocusAreaRecapView, selectedSection: $selectedSection, selectedSectionSummary: $selectedSectionSummary, selectedFocusArea: $selectedFocusArea, selectedEndOfTopicSection: $selectedEndOfTopicSection, focusAreaScrollPosition: $focusAreaScrollPosition, focusAreas: focusAreas)
            
        }
        .ignoresSafeArea(.keyboard)
        .overlay {
            if let scrollPosition = focusAreaScrollPosition {
                nextFocusAreaIndicator(scrollPosition: scrollPosition)
            }
        }
    }
    
    private func nextFocusAreaIndicator(scrollPosition: Int) -> some View {
        VStack {
            Spacer()

            if scrollPosition < focusAreas.count - 1 {
                VStack (spacing: 5){
                    Text(getNextFocusAreaDisplayNumber(scrollPosition: scrollPosition))
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                    
                    Text(getNextFocusAreaTitle(scrollPosition: scrollPosition))
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                        .onAppear {
                            print("Scroll position: \(scrollPosition), total focus area \(focusAreas.count)")
                        }
                        .padding(.bottom, 5)
                    
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
            
            return "\(nextFocusArea.focusAreaTitle)"
        } else {
            return ""
        }
    }

    private func getNextFocusAreaDisplayNumber(scrollPosition: Int) -> String {
        
        let totalFocusAreas = focusAreas.count
        let nextFocusAreaDisplayNumber = scrollPosition + 2 //the number displayed for focus area in UI
        
        if scrollPosition < totalFocusAreas - 2 {
            
            return "\(nextFocusAreaDisplayNumber)"
        }
        
        return ""
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
        .onChange(of: showFocusAreaRecapView) {
            if !showFocusAreaRecapView && dataController.newFocusArea {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        focusAreaScrollPosition = (focusAreaScrollPosition ?? 0) + 1
                    }
                    
                    //reset published var dataController.newFoucsArea, which tracks if a new focus area has just been created
                    dataController.newFocusArea = false
                }
                
            }
        }
        .onChange(of: focusAreaScrollPosition) {
            print("Scroll position updated to: \(focusAreaScrollPosition ?? -1)")
        }
        .onAppear {
           let activeFocusArea = focusAreas.first(where: { $0.focusAreaStatus == FocusAreaStatusItem.active.rawValue })
            
            let totalFocusAreas = focusAreas.count
            
            if let activeFocusArea = activeFocusArea {
                let scrollPosition = Int(activeFocusArea.orderIndex) - 1
                if scrollPosition >= 0 {
                    focusAreaScrollPosition = scrollPosition
                    print("set focus area scroll position: \(scrollPosition)")
                } else {
                    focusAreaScrollPosition = 0
                }
            } else {
                focusAreaScrollPosition = totalFocusAreas - 1
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
