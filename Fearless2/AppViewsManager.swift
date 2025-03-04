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
    
    @CloudStorage("currentCategory") var completedOnboarding: Int = 0
     
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
      
        switch completedOnboarding {
        case 0:
            OnboardingMainView()
        default:
            MainAppManager(dataController: dataController, openAISwiftService: openAISwiftService)
        }
    }
    
}



//#Preview {
//    AppViewsManager()
//}
