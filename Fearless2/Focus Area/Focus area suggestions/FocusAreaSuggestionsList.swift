//
//  FocusAreaSuggestionsList.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/27/24.
//
import Mixpanel
import SwiftUI

enum SuggestionsListUseCase {
    case newTopic
    case recap
}

struct FocusAreaSuggestionsList: View {
    
    @EnvironmentObject var dataController: DataController
    @ObservedObject var topicViewModel: TopicViewModel
    @State private var playHapticEffect: Int = 0
    @Binding var selectedTabSuggestionsList: Int
    
    let suggestions: [any SuggestionProtocol]
    private let screenWidth = UIScreen.current.bounds.width
    let suggestionBoxWidth:CGFloat = 220
    
    let action: () -> Void
    let topic: Topic?
    let focusArea: FocusArea?
    let useCase: SuggestionsListUseCase
    
    init(topicViewModel: TopicViewModel,
         selectedTabSuggestionsList: Binding<Int>,
         suggestions: [any SuggestionProtocol],
         action: @escaping () -> Void,
         topic: Topic?,
         focusArea: FocusArea? = nil,
         useCase: SuggestionsListUseCase) {
        
        self.topicViewModel = topicViewModel
        self._selectedTabSuggestionsList = selectedTabSuggestionsList
        self.suggestions = suggestions
        self.action = action
        self.topic = topic
        self.focusArea = focusArea
        self.useCase = useCase
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack (alignment: .top, spacing: 10) {
                switch selectedTabSuggestionsList {
                case 0:
                    LoadingPlaceholderContent(contentType: .suggestions)
                case 1:
                    suggestionsList()
                default:
                    FocusAreaRetryView(action: {
                        retryCreateSuggestions()
                    })
                    .frame(width: suggestionBoxWidth)
                }
               
            }//Hstack
            .scrollTargetLayout()
            
        }//Scrollview
        .scrollClipDisabled(true)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, (screenWidth - suggestionBoxWidth)/2, for: .scrollContent)
        .onAppear {
            switch useCase {
            case .newTopic:
                break
            case .recap:
                getViewTab()
            }
           
        }
        .onChange(of: topicViewModel.createFocusAreaSuggestions) {
            getViewTab()
        }
    }
    
    private func suggestionsList() -> some View {
        ForEach(suggestions, id: \.title) { suggestion in
            FocusAreaSuggestionBox(suggestion: suggestion, suggestionBoxWidth: suggestionBoxWidth, action: {
                createFocusArea(suggestion: suggestion, topic: topic)
            })
          
            .onTapGesture {
                playHapticEffect += 1
                createFocusArea(suggestion: suggestion, topic: topic)
            }
            .sensoryFeedback(.selection, trigger: playHapticEffect)
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.3)
                    .scaleEffect(x: phase.isIdentity ? 1 : 0.95, y: phase.isIdentity ? 1 : 0.95)
            }
        }
    }
    
    
    
    private func createFocusArea(suggestion: any SuggestionProtocol, topic: Topic?) {
        dataController.newFocusArea = true //to trigger scroll to new focus area
        topicViewModel.updatingfocusArea = true
        action()
        
        Task {
            //mark that a suggestion has been selected
            if let completedFocusArea = self.focusArea {
                await dataController.updateFocusArea(focusArea: completedFocusArea)
                
            }
            
            //save the suggestion as focus area
            guard let newFocusArea = await dataController.createFocusArea(suggestion: suggestion, topic: topic) else {
                return
            }
            //API call to create new focus area
            do {
                try await topicViewModel.manageRun(selectedAssistant: .focusArea, topicId: topic?.topicId, focusArea: newFocusArea)
               
            } catch {
                topicViewModel.focusAreaCreationFailed = true
            }

            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Chose new path")
            }
        }
    }
    
    private func getViewTab() {
        if topicViewModel.createFocusAreaSuggestions == .loading {
            selectedTabSuggestionsList = 0
        } else if topicViewModel.createFocusAreaSuggestions == .retry {
            selectedTabSuggestionsList = 2
        } else {
            selectedTabSuggestionsList = 1
        }
    }
    
    private func retryCreateSuggestions() {
        
        Task {
            do {
                try await topicViewModel.manageRun(selectedAssistant: .focusAreaSuggestions, topicId: topic?.topicId)
            } catch {
                selectedTabSuggestionsList = 2
            }
            
        }
        
    }
}

struct FocusAreaSuggestionBox: View {
   
    let suggestion: any SuggestionProtocol
    let suggestionBoxWidth: CGFloat
    let action: () -> Void
    
    var body: some View {
        VStack (spacing: 10) {

            Text(suggestion.title)
                .multilineTextAlignment(.center)
                .font(.system(size: 17, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            
            Text(suggestion.suggestionDescription)
                .multilineTextAlignment(.center)
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(AppColors.textPrimary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 20)
            
            Spacer()
            
            RoundButton(buttonImage: "checkmark", buttonAction: {
                action()
            })
           
        }
        .padding(25)
        .contentShape(Rectangle())
        .frame(width: suggestionBoxWidth, height: 250)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.boxGrey1.opacity(0.3))
                .shadow(color: .black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(.colorDodge)
        }
        
    }
}

