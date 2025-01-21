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
    @State private var selectedTab: Int = 1
    
    let suggestions: [any SuggestionProtocol]
    private let screenWidth = UIScreen.current.bounds.width
    
    let action: () -> Void
    let topic: Topic?
    let useCase: SuggestionsListUseCase
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack (alignment: .top, spacing: 15) {
                switch selectedTab {
                case 0:
                    placeholder()
                    
                default:
                    suggestionsList()
                }
               
            }//Hstack
            .scrollTargetLayout()
            
        }//Scrollview
        .scrollClipDisabled(true)
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, (screenWidth * 0.20)/2, for: .scrollContent)
        .onAppear {
            switch useCase {
            case .newTopic:
                break
            case .recap:
                if topicViewModel.creatingFocusAreaSuggestions {
                    selectedTab = 0
                }
            }
           
        }
        .onChange(of: topicViewModel.creatingFocusAreaSuggestions) {
            if !topicViewModel.creatingFocusAreaSuggestions {
                selectedTab = 1
            }
        }
    }
    
    private func suggestionsList() -> some View {
        ForEach(suggestions, id: \.title) { suggestion in
            FocusAreaSuggestionBox(suggestion: suggestion, action: {
                action()
                createFocusArea(suggestion: suggestion, topic: topic)
            })
            .frame(width: screenWidth * 0.80)
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.7)
                    .scaleEffect(y: phase.isIdentity ? 1 : 0.85)
            }
        }
    }
    
    private func placeholder() -> some View {
        ForEach(0..<2, id: \.self) { _ in
            LoadingPlaceholderContent(contentType: .suggestions)
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.7)
                        .scaleEffect(y: phase.isIdentity ? 1 : 0.85)
                }
        }
    }
    
    private func createFocusArea(suggestion: any SuggestionProtocol, topic: Topic?) {
    
        Task {
            //save the suggestion as focus area
            guard let focusArea = await dataController.createFocusArea(suggestion: suggestion, topic: topic) else {
                return
            }
            
            //API call to create new focus area
            await topicViewModel.manageRun(selectedAssistant: .focusArea, topicId: topic?.topicId, focusArea: focusArea)
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Chose new focus area")
            }
        }
    }
}

struct FocusAreaSuggestionBox: View {
   
    let suggestion: any SuggestionProtocol
    let action: () -> Void
    
    var body: some View {
        VStack (spacing: 10) {
            
            Text(suggestion.symbol)
                .font(.system(size: 35))
                .padding(.bottom, 10)

            Text(suggestion.title)
                .multilineTextAlignment(.center)
                .font(.system(size: 17))
                .foregroundStyle(AppColors.whiteDefault)
                .fixedSize(horizontal: false, vertical: true)

            
            Text(suggestion.suggestionDescription)
                .multilineTextAlignment(.center)
                .font(.system(size: 13))
                .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, 40)
            
            RectangleButtonYellow(
                buttonText: "Choose",
                action: {
                    action()
                })
        }
        .padding()
        .padding(.top, 20)
        .contentShape(Rectangle())
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(AppColors.whiteDefault.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.black5)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        }
        
    }
}

