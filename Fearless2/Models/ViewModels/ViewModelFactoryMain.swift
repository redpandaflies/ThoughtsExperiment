//
//  ViewModelFactoryMain.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 4/8/25.
//  Factory for all viewmodels that handles API calls to OpenAI

import Foundation

class ViewModelFactoryMain: ObservableObject {
    private let dataController: DataController
    private var openAISwiftService: OpenAISwiftService
    private var assistantRunManager: AssistantRunManager
    
    init(dataController: DataController) {
        self.dataController = dataController
        self.openAISwiftService = OpenAISwiftService(dataController: dataController)
        self.assistantRunManager = AssistantRunManager(
            openAISwiftService: openAISwiftService,
            dataController: dataController
        )
    }

    func makeUnderstandViewModel() -> UnderstandViewModel {
        return UnderstandViewModel(
            openAISwiftService: openAISwiftService,
            dataController: dataController
        )
    }
    
    func makeTopicViewModel() -> TopicViewModel {
        return TopicViewModel(
            dataController: dataController,
            openAISwiftService: openAISwiftService,
            assistantRunManager: assistantRunManager
        )
    }
    
    func makeSequenceViewModel() -> SequenceViewModel {
        return SequenceViewModel(
            dataController: dataController,
            openAISwiftService: openAISwiftService,
            assistantRunManager: assistantRunManager
        )
    }
}
