//
//  OpenAISwiftService.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//


import Combine
import CoreData
import Foundation
import OSLog
import SwiftOpenAI


final class OpenAISwiftService: ObservableObject {
    
    var functionContent: String = ""
    var threadId: String = ""
    var runId: String = ""
    var toolCallId: String = ""
    
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    
    private let openAIPartialKey = Constants.openAIPartialKey
    private var service: SwiftOpenAI.OpenAIService
    private var dataController: DataController
    
    init(dataController: DataController) {
        self.dataController = dataController
        self.service = OpenAIServiceFactory.service(aiproxyPartialKey: openAIPartialKey, aiproxyServiceURL: "https://api.aiproxy.pro/bf7d055e/e37b3324-720f-4b83-aa07-25eb3547173d")
    }
    
    //send recording to Whisper for transcript
    func getTranscript(newEntryId: String, data: Data) async -> String? {
        let fileName = "recording\(newEntryId).m4a"
        let parameters = AudioTranscriptionParameters(fileName: fileName, file: data)

        do {
            let audioObject = try await service.createTranscription(parameters: parameters)
            loggerOpenAI.info("Raw response from Whisper: \(String(describing: audioObject))")
            
            return audioObject.text
        } catch {
            loggerOpenAI.error("Failed to receive transcript from OpenAI: \(error.localizedDescription)")
            
            if let apiError = error as? APIError {
                // Handle specific cases of APIError
                switch apiError {
                case .requestFailed(let description):
                    loggerOpenAI.error("Request failed: \(description)")
                case .responseUnsuccessful(let description, let statusCode):
                    loggerOpenAI.error("Response unsuccessful (Status Code \(statusCode)): \(description)")
                case .invalidData:
                    loggerOpenAI.error("Invalid data received from OpenAI.")
                case .jsonDecodingFailure(let description):
                    loggerOpenAI.error("JSON decoding failure: \(description)")
                case .dataCouldNotBeReadMissingData(let description):
                    loggerOpenAI.error("Data missing: \(description)")
                case .bothDecodingStrategiesFailed:
                    loggerOpenAI.error("Both decoding strategies failed.")
                case .timeOutError:
                    loggerOpenAI.error("Request timed out.")
                }
            } else if let decodingError = error as? DecodingError {
                loggerOpenAI.error("Decoding Error: \(decodingError.localizedDescription)")
            } else {
                loggerOpenAI.error("Unexpected Error: \(error.localizedDescription)")
            }

            return nil
        }
    }

    func createThread() async throws -> String? {
        
        let parameters = CreateThreadParameters()
        
        do {
            let thread = try await service.createThread(parameters: parameters)
           
            loggerOpenAI.info("New thread created")
            
            self.threadId = thread.id
            
            return self.threadId
        } catch {
            loggerOpenAI.error("Failed to create thread: \(error.localizedDescription), \(error)")
            throw OpenAIError.requestFailed(error, "Failed to create thread")
        }
        
    }
    
    // Creates a message in a specific thread
    func createMessage(threadId: String, content: String) async throws -> AIMessage? {
        let parameters = SwiftOpenAI.MessageParameter(role: .user, content: .stringContent(content))
        
        do {
            let messageResponse = try await service.createMessage(
                threadID: threadId, parameters: parameters)
            return AIMessage(
                id: UUID(),
                threadId: threadId,
                role: SenderRole.user,
                content: content,
                createdAt: Date(timeIntervalSince1970: TimeInterval(messageResponse.createdAt))
            )
            
        } catch {
            loggerOpenAI.error("Error when creating the message: \(error.localizedDescription). \(error)")
            throw OpenAIError.requestFailed(error, "Failed to send message to OpenAI")
        }
        
    }
    
    func createRunAndStreamMessage(threadId: String, selectedAssistant: AssistantItem) async throws -> String? {
        await MainActor.run {
            self.functionContent = ""
            self.toolCallId = ""
        }
        
        let timeoutSeconds: Double = 45
        
        return try await withTimeout(seconds: timeoutSeconds) { [weak self] in
            guard let self = self else { throw OpenAIError.runIncomplete() }
            
            
            var messageText: String = ""
            
            guard let selectedAssistantId = selectedAssistant.getAssistantId() else {
                loggerOpenAI.error("Assistant ID missing.")
                throw OpenAIError.missingRequiredField("Assistant ID missing")
            }
            
            do {
                let stream = try await service.createRunStream(threadID: threadId, parameters: .init(assistantID: selectedAssistantId))
                
                for try await result in stream {
                    
                    switch result {
                        
                    case .threadRunQueued(let data):
                        //need runID to cancel run
                        self.runId = data.id
                        loggerOpenAI.log("Got run ID: \(self.runId)")
                        
                        continue
                        
                    case .threadMessageDelta(let messageDelta):
                        let content = messageDelta.delta.content.first
                        switch content {
                        case .imageFile, nil:
                            break
                        case .text(let textContent):
                            
                            if !textContent.text.value.isEmpty {
                                messageText += textContent.text.value
                                loggerOpenAI.log("messageText: \(messageText)")
                            }
                            
                            break
                        }
                        
                    case .threadRunStepDelta(let runStepDelta):
                        
                        loggerOpenAI.log("Received function call result from OpenAI")
                        
                        let toolCall = runStepDelta.delta.stepDetails.toolCalls?.first?.toolCall
                        
                        switch toolCall {
                        case .functionToolCall(let toolCall):
                            self.functionContent += toolCall.arguments
                            loggerOpenAI.log("Toolcall arguments from OpenAI: \(self.functionContent)")
                            
                        default:
                            loggerOpenAI.log("Tool call case isn't functionToolCall")
                            break
                        }
                        
                        
                    case .done:
                        loggerOpenAI.log("Stream complete")
                        break
                        
                    case .error, .threadRunStepFailed, .threadMessageIncomplete:
                        loggerOpenAI.log("Error ocurred while streaming")
                        throw OpenAIError.runIncomplete()
                        
                    case .threadRunFailed(let error) :
                        loggerOpenAI.log("Error ocurred while streaming: \(error.status); \(error.lastError.debugDescription)")
                        throw OpenAIError.runIncomplete(nil, error.lastError.debugDescription)
                        
                    default:
                        continue
                    }
                }//for try await
                
                return messageText
                
            }  catch {
                loggerOpenAI.error("Error when streaming run: \(error.localizedDescription), \(error)")
                throw OpenAIError.runIncomplete(error) // End the loop in the event of an error
            }
        }
        
    }
    
   private func withTimeout<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            // Add the main operation
            group.addTask {
                try await operation()
            }
            
            // Add the timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                self.loggerOpenAI.warning("Streamed run timed out after \(seconds) seconds")
                
                do {
                    try await self.cancelRun()
                } catch {
                    self.loggerOpenAI.error("Failed to cancel OpenAI run: \(error.localizedDescription)")
                }
                
                throw OpenAIError.streamingTimeout
            }

            guard let result = try await group.next() else {
                group.cancelAll()
                throw OpenAIError.runIncomplete(nil, "Unexpected error: No task completed.")
            }

            group.cancelAll() // Cancel the remaining task
            return result
        }
    }
    
    //cancel run
    func cancelRun() async throws {
        do {
            let run = try await service.cancelRun(threadID: self.threadId, runID: self.runId)
            loggerOpenAI.info("Successfully cancelled run: \(run.id)")
            
        } catch {
            loggerOpenAI.error("Failed to cancel run: \(error.localizedDescription), \(error)")
            throw OpenAIError.requestFailed(error, "failed to cancel run")
        }
        
    }
    
}

//process data
extension OpenAISwiftService {
    
    private func decodeArguments<T: Decodable>(arguments: String, as type: T.Type) -> T? {
        guard let data = arguments.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private func saveCoreDataChanges(context: NSManagedObjectContext, errorDescription: String) throws {
        do {
            try context.save()
        } catch {
            self.loggerCoreData.error("Failed to save changes for \(errorDescription): \(error.localizedDescription), \(error)")
            throw CoreDataError.saveFailed(error, errorDescription)
        }
    }
    
    // MARK: New Category summary
    func processCreateCategorySummary(messageText: String, goal: Goal) async throws -> NewCreateCategorySummary? {
        let arguments = messageText
        let context = self.dataController.container.viewContext
        // Decode the arguments to get the category summary
        guard let categorySummary = self.decodeArguments(arguments: arguments, as: NewCreateCategorySummary.self) else {
            loggerOpenAI.error("Couldn't decode arguments for category summary.")
            throw ProcessingError.decodingError("category summary")
        }
        
        //add goal attributes
        try await context.perform {
            goal.goalProblemLong = categorySummary.summary
            goal.goalTitle = categorySummary.goal.title
            goal.goalProblem = categorySummary.goal.problem
            goal.goalResolution = categorySummary.goal.resolution
            
            try self.saveCoreDataChanges(context: context, errorDescription: "new goal")
        }
        
        
        return categorySummary
    }
    // MARK: Plan suggestions
    func processPlanSuggestions(messageText: String) async throws -> NewPlanSuggestions? {
        let arguments = messageText
        
        // Decode the arguments to get the plan suggestions
        guard let planSuggestions = self.decodeArguments(arguments: arguments, as: NewPlanSuggestions.self) else {
            loggerOpenAI.error("Couldn't decode arguments for plan suggestions.")
            throw ProcessingError.decodingError("plan suggestions")
        }
        
        return planSuggestions
    }
    
    // MARK: Create focus areas for a topic
    func processTopicGenerated(messageText: String) async throws -> NewTopicGenerated? {
        let arguments = messageText
        
        // Decode the arguments to get the new topic suggestions
        guard let newSuggestions = self.decodeArguments(arguments: arguments, as: NewTopicGenerated.self) else {
            loggerOpenAI.error("Couldn't decode arguments for topic suggestions.")
            throw ProcessingError.decodingError("topic suggestions")
        }
        
        return newSuggestions
    }
    
    // MARK: Plan/sequence summary
    @MainActor
    func processSequenceSummary(messageText: String, sequence: Sequence?) async throws {
        let arguments = messageText
        let context = self.dataController.container.viewContext
        
       try await context.perform {
            // Decode the arguments to get the new section data
           guard let summaries = self.decodeArguments(arguments: arguments, as: NewSequenceSummaries.self) else {
                self.loggerOpenAI.error("Couldn't decode arguments for sequence summaries.")
                throw ProcessingError.decodingError("sequence summaries")
            }
           
           guard let sequence = sequence else {
               self.loggerOpenAI.error("Couldn't find sequence to update.")
               throw ProcessingError.missingRequiredField("sequence")
           }
           
           guard let goal = sequence.goal else {
               self.loggerOpenAI.error("Couldn't find goal to update.")
               throw ProcessingError.missingRequiredField("goal")
           }
           
           for summary in summaries.summaries {
               let newSummary = SequenceSummary(context: context)
               newSummary.summaryId = UUID()
               newSummary.summaryCreatedAt = getCurrentTimeString()
               newSummary.summaryContent = summary.content
               newSummary.orderIndex = Int16(summary.summaryNumber)
            
               sequence.addToSummaries(newSummary)
               goal.addToSequenceSummaries(newSummary)
               if let category = sequence.category {
                   category.addToSequenceSummaries(newSummary)
               }
               
           }
            // Save to coredata
           try self.saveCoreDataChanges(context: context, errorDescription: "sequence summaries")
            
        }
    }
    
    
    @MainActor
    func processTopicOverview(messageText: String, topic: Topic) async throws {
        let arguments = messageText
        let context = self.dataController.container.viewContext
        
        // Decode the arguments to get the new section data
        guard let newReview = self.decodeArguments(arguments: arguments, as: NewTopicOverview.self) else {
            self.loggerOpenAI.error("Couldn't decode arguments for topic review.")
            throw ProcessingError.decodingError("topic review")
        }

       try await context.perform {

            let review = TopicReview(context: context)
            review.reviewId = UUID()
            review.reviewCreatedAt = getCurrentTimeString()
            review.reviewOverview = newReview.overview
            review.reviewSummary = newReview.summary
            review.overviewGenerated = true
            topic.assignReview(review)
              
          
            // Save to coredata
           try self.saveCoreDataChanges(context: context, errorDescription: "new topic review")
            
        }
    }
    
    @MainActor
    func processTopicBreak(messageText: String, topic: Topic) async throws {
        let arguments = messageText
        let context = self.dataController.container.viewContext
        
        // Decode the arguments to get the new section data
        guard let newBreak = self.decodeArguments(arguments: arguments, as: NewTopicBreak.self) else {
            self.loggerOpenAI.error("Couldn't decode arguments for topic break.")
            throw ProcessingError.decodingError("topic break")
        }

       try await context.perform {
            
           for card in newBreak.cards {
               let topicBreak = TopicBreak(context: context)
               topicBreak.breakId = UUID()
               topicBreak.breakContent = card.cardContent
               topicBreak.orderIndex = Int16(card.cardNumber)
               topic.addToBreaks(topicBreak)
               
           }
            // Save to coredata
           try self.saveCoreDataChanges(context: context, errorDescription: "new topic break")
            
        }
    }
    
    @MainActor
    func processNewTopicQuestions(messageText: String, topic: Topic) async throws {
        let arguments = messageText
        let context = self.dataController.container.viewContext

        try await context.perform {
            
            // decode the arguments to get the new section data
            guard let newQuestions = self.decodeArguments(arguments: arguments, as: NewTopicQuestions.self) else {
                self.loggerOpenAI.log("Failed to decode new questions for topic: \(topic.topicTitle)")
                throw ProcessingError.decodingError("New topic questions")
            }
            
            // add sections to topic
            self.processQuestions(newQuestions.questions, for: topic, in: context)
            
            try self.saveCoreDataChanges(context: context, errorDescription: "New topic questions")
            
        }
    }
    
    private func processQuestions(_ newQuestions: [NewQuestion], for topic: Topic, in context: NSManagedObjectContext) {
           for newQuestion in newQuestions {
               let question = Question(context: context)
               question.questionId = UUID()
               question.questionContent = newQuestion.content
               question.questionNumber = Int16(newQuestion.questionNumber)
               question.questionType = newQuestion.questionType.rawValue
               
               if newQuestion.questionType == .singleSelect {
                   question.questionSingleSelectOptions = newQuestion.options.map {$0.text}.joined(separator: ";")
                  
               } else if newQuestion.questionType == .multiSelect {
                   question.questionMultiSelectOptions = newQuestion.options.map {$0.text}.joined(separator: ";")
                   
               }
               
               // Add the question to the section
               topic.addToQuestions(question)
           }
       }
    
    @MainActor
    func processFocusAreaSummary(messageText: String, focusArea: FocusArea) async throws {
        let arguments = messageText
        let context = self.dataController.container.viewContext

        try await context.perform {
            // Decode the arguments to get the new topic data
            guard let newSummary = self.decodeArguments(arguments: arguments, as: NewFocusAreaSummary.self) else {
                self.loggerOpenAI.error("Couldn't decode arguments for focus area recap.")
                throw ProcessingError.decodingError("new focus area recap")
            }
            
            //focus area topic
            guard let topic = focusArea.topic else {
                self.loggerOpenAI.error("Couldn't create summary for focus area without topic.")
                throw ProcessingError.missingRequiredField("Related topic not found")
            }
            
            //create entry
            let summary: FocusAreaSummary
            summary = FocusAreaSummary(context: context)
            summary.summaryId = UUID()
            summary.summaryCreatedAt = getCurrentTimeString()
            summary.summarySummary = newSummary.summary
            summary.summaryFeedback = newSummary.feedback
            focusArea.assignSummary(summary)
            
            //update entry insights
            for newInsight in newSummary.insights {
                let insight = Insight(context: context)
                insight.insightId = UUID()
                insight.insightContent = newInsight.content
                summary.addToInsights(insight)
                topic.addToInsights(insight)
            }
            
            //Save the context
            try self.saveCoreDataChanges(context: context, errorDescription: "new focus area recap")
        }
    }
    
    @MainActor
    func processSectionSummary(messageText: String, section: Section) async {
        let arguments = messageText
        let context = self.dataController.container.viewContext

        await context.perform {
            // Decode the arguments to get the new topic data
            guard let newSummary = self.decodeArguments(arguments: arguments, as: NewSectionSummary.self) else {
                self.loggerOpenAI.error("Couldn't decode arguments for section summary.")
                return
            }
            
            guard let topic = section.topic else {
                self.loggerOpenAI.error("Couldn't create summary for section without topic.")
                return
            }
            
            //create entry
            let summary: SectionSummary
            summary = SectionSummary(context: context)
            summary.summaryId = UUID()
            summary.summaryCreatedAt = getCurrentTimeString()
            summary.summarySummary = newSummary.summary
            summary.summaryFeedback = newSummary.feedback
            section.assignSummary(summary)
            
            //update entry insights
            for newInsight in newSummary.insights {
                let insight = Insight(context: context)
                insight.insightId = UUID()
                insight.insightContent = newInsight.content
                summary.addToInsights(insight)
                topic.addToInsights(insight)
            }
            
            //save the context
            do {
                try context.save()
            } catch {
                self.loggerCoreData.error("Error saving summary: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func processEntry(messageText: String, entryId: UUID) async -> Entry? {
        let arguments = messageText
        let context = self.dataController.container.viewContext
        
        var currentEntry: Entry? = nil
        
        await context.perform {
            
            // Fetch the entry with the provided entryId
            let request = NSFetchRequest<Entry>(entityName: "Entry")
            request.predicate = NSPredicate(format: "id == %@", entryId as CVarArg)
            
            do {
                guard let entry = try context.fetch(request).first else {
                    self.loggerCoreData.error("No entry found with entryId: \(entryId)")
                    return
                }
                
                
                // Decode the arguments to get the new topic data
                guard let newEntry = self.decodeArguments(arguments: arguments, as: NewEntry.self) else {
                    self.loggerOpenAI.error("Couldn't decode arguments for section summary.")
                    return
                }
               
                //create entry
                entry.entryTitle = newEntry.title
                entry.entrySummary = newEntry.summary
                entry.entryFeedback = newEntry.feedback
                
                //Update entry insights
                for newInsight in newEntry.insights {
                    let insight = Insight(context: context)
                    insight.insightId = UUID()
                    insight.insightCreatedAt = getCurrentTimeString()
                    insight.insightContent = newInsight.content
                    entry.addToInsights(insight)
                    if let topic = entry.topic {
                        topic.addToInsights(insight)
                    }
                }

                //set return value
                currentEntry = entry
                
            } catch {
                self.loggerCoreData.error("Error fetching entry: \(error.localizedDescription)")
                return
            }
            //Save the context
            do {
                try context.save()
            } catch {
                self.loggerCoreData.error("Error saving new entry: \(error.localizedDescription)")
                return
            }
        }
        
        return currentEntry
    }
    
    @MainActor
    func processFocusAreaSuggestions(messageText: String, topicId: UUID) async throws {
        let arguments = messageText
        let context = self.dataController.container.viewContext
       
        //delete all existing suggestions
        let topic = try await self.dataController.deleteTopicSuggestions(topicId: topicId)
        
        //decode new suggestions
        try await context.perform {
            
            guard let newSuggestions = self.decodeArguments(arguments: arguments, as: NewFocusAreaSuggestions.self) else {
                self.loggerOpenAI.error("Couldn't decode arguments for focus area suggestions.")
                throw ProcessingError.decodingError("focus area suggestions")
            }
            
            for item in newSuggestions.suggestions {
                let newSuggestion = FocusAreaSuggestion(context: context)
                newSuggestion.suggestionId = UUID()
                newSuggestion.suggestionEmoji = item.emoji
                newSuggestion.suggestionContent = item.content
                newSuggestion.suggestionReasoning = item.reasoning
                if let currentTopic = topic {
                    currentTopic.addToSuggestions(newSuggestion)
                }
            }
            
            //save new suggestions
            try self.saveCoreDataChanges(context: context, errorDescription: "focus area suggestions")
            
        }
    }
    
    @MainActor
    func processUnderstandAnswer(messageText: String, question: String) async -> Understand? {
        let arguments = messageText
        let context = self.dataController.container.viewContext
        
        var newUnderstand: Understand? = nil
        
        await context.perform {
            
            guard let newAnswer = self.decodeArguments(arguments: arguments, as: NewUnderstandAnswer.self) else {
                self.loggerOpenAI.error("Couldn't decode arguments for section summary.")
                return
            }
            
            //create entry
            let understand = Understand(context: context)
            understand.understandId = UUID()
            understand.understandCreatedAt = getCurrentTimeString()
            understand.understandAnswer = newAnswer.answer
            understand.understandQuestion = question
            newUnderstand = understand
            
            //save the context
            do {
                try context.save()
            } catch {
                self.loggerCoreData.error("Error saving topic: \(error.localizedDescription)")
            }
        }
        
        return newUnderstand
    }
    
}


struct AITranscript: Decodable {
    let text: String
}

struct AIMessage: Identifiable, Decodable {
    let id: UUID
    let threadId: String
    let role: SenderRole
    var content: String
    let createdAt: Date
}

enum SenderRole: String, Codable {
    case user
    case assistant
}

// MARK: Create new category "hear's what I heard"
struct NewCreateCategorySummary: Codable, Hashable {
    let summary: String
    let goal: NewGoal
}

struct NewGoal: Codable, Hashable {
    let title: String
    let problem: String
    let resolution: String
}

// MARK: Plan suggestions
struct NewPlanSuggestions: Codable, Hashable {
    let plans: [NewPlan]
}


struct NewPlan: Codable, Hashable {
    let title: String
    let intent: String
    let explore: [String]
    let expectations: [NewExpectation]
    let quests: [NewTopic1]
}

struct NewTopic1: Codable, Hashable {
    let questNumber: Int
    let title: String
    let objective: String
    let emoji: String
    let questType: String
    
    enum CodingKeys: String, CodingKey {
        case questNumber = "quest_number"
        case title
        case objective
        case emoji
        case questType = "quest_type"
    }
}

// MARK: Plan expectations
struct NewExpectation: Codable, Hashable {
    let expectationsNumber: Int
    let content: String

    enum CodingKeys: String, CodingKey {
        case expectationsNumber = "expectations_number"
        case content
    }
}

// MARK: Plan/sequence summary
struct NewSequenceSummaries: Codable, Hashable {
    let summaries: [NewSequenceSummary]
}

struct NewSequenceSummary: Codable, Hashable {
    let summaryNumber: Int
    let content: String

    enum CodingKeys: String, CodingKey {
        case summaryNumber = "summary_number"
        case content
    }
}

struct NewTopic: Codable, Hashable {
    let title: String
    let definition: String
    let suggestions: [NewSuggestion]
}

//Create topic overview
struct NewTopicOverview: Codable, Hashable {
    let overview: String
    let summary: String
}

//Create topic suggestions
struct NewTopicGenerated: Codable, Hashable {
    let focusAreas: [NewFocusAreaHeading]
    
    enum CodingKeys: String, CodingKey {
        case focusAreas = "focus_areas"
    }
}

// focus area generated with topic suggestions
struct NewFocusAreaHeading: Codable, Hashable {
    let focusAreaNumber: Int
    let content: String
    let reasoning: String
    let emoji: String
    
    enum CodingKeys: String, CodingKey {
        case focusAreaNumber = "focusArea_number"
        case content
        case reasoning
        case emoji
    }
}


// MARK: Create topic questions
struct NewTopicQuestions: Codable, Hashable {
    let questions: [NewQuestion]
}

//question belongs to a section
struct NewQuestion: Codable, Hashable {
    let content: String
    let questionNumber: Int
    let questionType: QuestionType
    let options: [Option]
    
    enum CodingKeys: String, CodingKey {
        case content
        case questionNumber = "question_number"
        case questionType = "question_type"
        case options
    }
}

enum QuestionType: String, Codable {
    case open
    case singleSelect
    case multiSelect
}

struct Option: Codable, Hashable {
    let text: String
}

// MARK: Create topic break
struct NewTopicBreak: Codable, Hashable {
    let cards: [NewBreakCard]
}

struct NewBreakCard: Codable, Hashable {
    let cardNumber: Int
    let cardContent: String

    enum CodingKeys: String, CodingKey {
        case cardNumber = "card_number"
        case cardContent = "card_content"
    }
}

// MARK: - Not in use
//focus area summary
struct NewFocusAreaSummary: Codable, Hashable {
    let summary: String
    let feedback: String
    let insights: [NewInsight]
}

//section summary
struct NewSectionSummary: Codable, Hashable {
    let summary: String
    let feedback: String
    let insights: [NewInsight]
}

//insight
struct NewInsight: Codable, Hashable {
    let content: String
}

//focus area suggestions
struct NewFocusAreaSuggestions: Codable, Hashable {
    let suggestions: [NewSuggestion]
}

struct NewSuggestion: Codable, Hashable {
    let content: String
    let reasoning: String
    let emoji: String
}

//entry
struct NewEntry: Codable, Hashable {
    let title: String
    let summary: String
    let feedback: String
    let insights: [NewInsight]
}

//understand answer
struct NewUnderstandAnswer: Codable, Hashable {
    let answer: String
}
