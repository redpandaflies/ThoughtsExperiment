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
    
    func makeNewGoalViewModel() -> NewGoalViewModel {
        let context = dataController.container.viewContext
        let goalProcessor = GoalProcessor(context: context)
        
        return NewGoalViewModel(
            dataController: dataController,
            goalProcessor: goalProcessor,
            assistantRunManager: assistantRunManager
        )
    }
    
    func makeTopicViewModel() -> TopicViewModel {
        let context = dataController.container.viewContext
        let topicProcessor = TopicProcessor(context: context)
        
        return TopicViewModel(
            dataController: dataController,
            topicProcessor: topicProcessor,
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
    
    func makeDailyTopicViewModel() -> DailyTopicViewModel {
        let context = dataController.container.viewContext
        let topicProcessor = TopicProcessor(context: context)
        let goalProcessor = GoalProcessor(context: context)
        
        return DailyTopicViewModel(
            dataController: dataController,
            topicProcessor: topicProcessor,
            goalProcessor: goalProcessor,
            assistantRunManager: assistantRunManager
            
        )
    }
}
