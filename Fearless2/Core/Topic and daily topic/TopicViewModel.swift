//
//  TopicViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//
import Combine
import CoreData
import Foundation
import OSLog
import UIKit
import SwiftUI

final class TopicViewModel: ObservableObject, TopicRecapObservable {
    
    // manage API calls states
    @Published var createTopicRecap: LoadingStatePrimary = .ready
    @Published var createTopicQuestions: LoadingStatePrimary = .ready
    @Published var createTopicBreak: LoadingStatePrimary = .ready
    
    var createTopicRecapPublisher: Published<LoadingStatePrimary>.Publisher { $createTopicRecap }
    var completedLoadingAnimationSummaryPublisher: Published<Bool>.Publisher { $completedLoadingAnimationSummary }
    
    // manage UI updates
    /// triggers update of progress bar for sequence (plan)
    @Published var completedNewTopic: Bool = false
    @Published var completedLoadingAnimationSummary: Bool = false
    
    // not in use
    @Published var createNewFocusArea: LoadingStatePrimary = .ready
    @Published var focusAreaCreationFailed: Bool = false //when run fails
    @Published var createFocusAreaSummary: LoadingStatePrimary = .ready
    @Published var sectionSummaryCreated: Bool = false
    @Published var scrollToAddTopic: Bool = false
    @Published var showPlaceholder: Bool = false
    @Published var generatingImage: Bool = false
    @Published var updatedEntry: Entry? = nil 
  
    private var dataController: DataController
    private var topicProcessor: TopicProcessor
    private var assistantRunManager: AssistantRunManager
    private var stabilityService = StabilityService.instance
    
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var cancellables = Set<AnyCancellable>()
    
    var threadId: String? = nil //needed for cancelling runs
    
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    let loggerStability = Logger.stabilityEvents
    
    init(
        dataController: DataController,
        topicProcessor: TopicProcessor,
        assistantRunManager: AssistantRunManager
    ) {
        self.dataController = dataController
        self.topicProcessor = topicProcessor
        self.assistantRunManager = assistantRunManager
    }
    
    //MARK: create new topic
    //note: send the full name of category to GPT as context, save the short name to CoreData
    //note: kept the optionals for userInput and question for now, in case we want to add back in the follow-up questions and summary
    func manageRun(selectedAssistant: AssistantItem, userInput: [String]? = nil, topicId: UUID? = nil, entryId: UUID? = nil, transcript: String? = nil, topic: Topic? = nil, focusArea: FocusArea? = nil, section: Section? = nil, question: String? = nil, review: TopicReview? = nil, category: Category? = nil) async throws {
        
        // Start a background task to give iOS extra time when you go background
        await MainActor.run {
            // capture the task ID in a local constant
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask (withName: "Finish Network Tasks") {
                // End the task if time expires.
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
                    self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
                }
        }

        defer {
          Task { @MainActor in
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
              self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
          }
        }
        
        do {
            //reset published vars
            await MainActor.run {
                self.threadId = nil
                self.showPlaceholder = false
                self.generatingImage = false
                if selectedAssistant == .focusArea {
                    if self.createNewFocusArea != .loading {
                        self.createNewFocusArea = .loading
                    }
                } else {
                    self.createNewFocusArea = .ready
                }
                if selectedAssistant == .focusAreaSummary {
                    self.createFocusAreaSummary = .loading
                } else {
                    self.createFocusAreaSummary = .ready
                }
                if selectedAssistant == .topicOverview {
                    self.createTopicRecap = .loading
                }
                
                if selectedAssistant == .topicBreak {
                    self.createTopicBreak = .loading
                }
                if selectedAssistant == .topic {
                    if self.createTopicQuestions != .loading {
                        self.createTopicQuestions = .loading
                    }
                }
                self.sectionSummaryCreated = false
                self.updatedEntry = nil
                
            }
            
            try await manageRunWithStreaming(selectedAssistant: selectedAssistant, userInput: userInput, topicId: topicId, entryId: entryId, transcript: transcript, topic: topic, focusArea: focusArea, section: section, question: question, review: review,  category: category)
            
        } catch {
            loggerOpenAI.error("Failed to complete OpenAI run: \(error.localizedDescription), \(error)")
            throw OpenAIError.runIncomplete(error)
            
        }
        
    }
    
    func manageRunWithStreaming(selectedAssistant: AssistantItem, userInput: [String]? = nil, topicId: UUID? = nil, entryId: UUID? = nil, transcript: String? = nil, topic: Topic? = nil, focusArea: FocusArea? = nil, section: Section? = nil, question: String? = nil, review: TopicReview? = nil, category: Category? = nil) async throws {
        
        do {
            let messageText = try await assistantRunManager.runAssistant(
                selectedAssistant: selectedAssistant,
                category: category,
                topicId: topicId,
                focusArea: focusArea,
                topic: topic
            )
            
            switch selectedAssistant {
                
            case .topic:
                guard let topic = topic else {
                    loggerCoreData.error("Failed to get topic")
                    return
                }
                
                try await topicProcessor.processNewTopicQuestions(messageText: messageText, topic: topic)
                
                await MainActor.run {
                    self.createTopicQuestions = .ready
                }
                
            case .topicOverview:
                
                guard let topic = topic else {
                    loggerCoreData.error("Failed to get topic")
                    return
                }
                
                try await topicProcessor.processTopicOverview(messageText: messageText, topic: topic)
                
                await MainActor.run {
                    self.createTopicRecap = .ready
                }
                
            case .topicBreak:
                guard let topic = topic else {
                    loggerCoreData.error("Failed to get topic")
                    return
                }
                
                try await topicProcessor.processTopicBreak(messageText: messageText, topic: topic)
                
                await MainActor.run {
                    self.createTopicBreak = .ready
                }
                
                
            default:
                break
            }
            
            
        } catch {
            loggerOpenAI.error("Failed to decode OpenAI streamed response: \(error.localizedDescription), \(error)")
            throw ProcessingError.processingFailed(error)
            
        }
        
    }
    
    func cancelCurrentRun() async throws {
        do {
            try await assistantRunManager.cancelCurrentRun()
        } catch {
            throw OpenAIError.missingRequiredField("No thread ID found")
        }
    }
    
    func markCompleteLoadingAnimationSummary() {
        completedLoadingAnimationSummary = true
    }
    
    // MARK: - Save data to coredata
    
    // save answer to topic question
    @MainActor
    func saveAnswer(
        questionType: QuestionType,
        topic: TopicRepresentable?,
        questionContent: String? = nil,
        questionId: UUID? = nil,
        userAnswer: Any,
        customItems: [String]? = nil
    ) async {
        do {
            try await topicProcessor.saveAnswer(
                questionType: questionType,
                topic: topic,
                questionContent: questionContent,
                questionId: questionId,
                userAnswer: userAnswer,
                customItems: customItems
            )
           
        } catch {
            loggerCoreData.error("\(error.localizedDescription)")
        }
    }
    
    //mark topic complete
    @MainActor
    func completeTopic(topic: TopicRepresentable) async {
        do {
            try await topicProcessor.completeTopic(topic: topic)
        } catch {
            loggerCoreData.error("\(error.localizedDescription)")
        }
    }
    
    @MainActor
    func deleteIncompleteGoals(_ goals: FetchedResults<Goal>) async {
        do {
            // Filter goals with empty goalSequences
            let incompleteGoals = goals.filter { $0.goalSequences.isEmpty }
            
            if !incompleteGoals.isEmpty {
                try await topicProcessor.deleteIncompleteGoals(incompleteGoals)
            }
            
        } catch {
            loggerCoreData.error("\(error.localizedDescription)")
        }
        
    }
    
}

//MARK: generate topic image
extension TopicViewModel {
    
    func getTopicImage(topic: Topic) async {
        
        
        let topicId = await MainActor.run {
            return topic.topicId.uuidString
        }
        
        let newImagePrompt = await MainActor.run {
            return "A beautifully rendered minimalistic 3d illustration of this theme: \(topic.topicTitle). Incorporate subtle cinematic lighting and details that capture the essence of the theme."
        }
        
        loggerStability.log("Creating image for topic: \(topicId)")
        
        //get image from Stability
        if let topicImageURL = await stabilityService.getTopicImage(fromPrompt: newImagePrompt, topicId: topicId) {
            
            await dataController.saveTopicImage(topic: topic, imageURL: topicImageURL.absoluteString)
            
            await MainActor.run {
                self.generatingImage = false
            }
        } else {
            await MainActor.run {
                self.showPlaceholder = true
                self.generatingImage = false
            }
        }
        
    }
    
}
