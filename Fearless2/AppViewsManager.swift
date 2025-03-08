//
//  AppViewsManager.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//
import CloudStorage
import SwiftUI

struct AppViewsManager: View {
    
    @EnvironmentObject var dataController: DataController
    @EnvironmentObject var openAISwiftService: OpenAISwiftService

//    @StateObject var transcriptionViewModel: TranscriptionViewModel
//    @StateObject var understandViewModel: UnderstandViewModel
//    @StateObject var topicViewModel: TopicViewModel
    
    @CloudStorage("currentAppView") var currentAppView: Int = 0
     
    init(dataController: DataController, openAISwiftService: OpenAISwiftService) {

//        let transcriptionViewModel = TranscriptionViewModel(openAISwiftService: openAISwiftService, dataController: dataController)
//        let understandViewModel = UnderstandViewModel(openAISwiftService: openAISwiftService, dataController: dataController)
//        
//        _transcriptionViewModel = StateObject(wrappedValue: transcriptionViewModel)
//        _understandViewModel = StateObject(wrappedValue: understandViewModel)
//        
//        let topicViewModel = TopicViewModel(openAISwiftService: openAISwiftService, dataController: dataController, transcriptionViewModel: transcriptionViewModel)
//        _topicViewModel = StateObject(wrappedValue: topicViewModel)
//        
        
    }

    var body: some View {
      
        switch currentAppView {
        case 0:
            OnboardingMainView()
        case 1:
            MainAppManager(dataController: dataController, openAISwiftService: openAISwiftService)
        default:
            NewCategoryView()
                .transition(.asymmetric(insertion: .opacity, removal: .identity))
        }
    }
    
}



//#Preview {
//    AppViewsManager()
//}
