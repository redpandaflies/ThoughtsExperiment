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
        
        let timeoutSeconds: Double = 30
        
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
                    try await self.cancelRun(threadId: self.threadId)
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
    func cancelRun(threadId: String) async throws {
        do {
            let run = try await service.cancelRun(threadID: threadId, runID: self.runId)
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
    
    @MainActor
    func processNewTopic(messageText: String, topicId: UUID) async throws -> Topic? {
        let arguments = messageText
        let context = self.dataController.container.viewContext
        var fetchedTopic: Topic? = nil
        
        try await context.perform {
            // Fetch the topic with the provided topicId
            let request = NSFetchRequest<Topic>(entityName: "Topic")
            request.predicate = NSPredicate(format: "id == %@", topicId as CVarArg)

            
            guard let topic = try context.fetch(request).first else {
                self.loggerCoreData.error("No topic found with topicId: \(topicId)")
                throw ProcessingError.missingRequiredField("Existing topic not found")
            }
            
            // Decode the arguments to get the new section data
            guard let newTopic = self.decodeArguments(arguments: arguments, as: NewTopic.self) else {
                self.loggerOpenAI.error("Couldn't decode arguments for new topic: \(topic.topicTitle).")
                throw ProcessingError.decodingError("new topic")
            }
            
            
            topic.topicTitle = newTopic.title
            topic.topicDefinition = newTopic.definition
            
            for newSuggestion in newTopic.suggestions {
                let suggestion = FocusAreaSuggestion(context: context)
                suggestion.suggestionId = UUID()
                suggestion.suggestionContent = newSuggestion.content
                suggestion.suggestionReasoning = newSuggestion.reasoning
                suggestion.suggestionEmoji = newSuggestion.emoji
                topic.addToSuggestions(suggestion)
            }
            
            //update fetchedTopic
            fetchedTopic = topic

            // Save the context after processing each section and its questions
            try self.saveCoreDataChanges(context: context, errorDescription: "new topic")
        }
        
        return fetchedTopic
    }
    
    func processTopicSuggestions(messageText: String) async throws -> NewTopicSuggestions? {
        let arguments = messageText
        
        // Decode the arguments to get the new topic suggestions
        guard let newSuggestions = self.decodeArguments(arguments: arguments, as: NewTopicSuggestions.self) else {
            loggerOpenAI.error("Couldn't decode arguments for topic suggestions.")
            throw ProcessingError.decodingError("topic suggestions")
        }
        
        return newSuggestions
    }

    
    @MainActor
    func processTopicOverview(messageText: String, topicId: UUID) async throws {
        let arguments = messageText
        let context = self.dataController.container.viewContext
        
       try await context.perform {
            // Fetch the topic with the provided topicId
            let request = NSFetchRequest<Topic>(entityName: "Topic")
            request.predicate = NSPredicate(format: "id == %@", topicId as CVarArg)

   
            guard let topic = try context.fetch(request).first else {
                self.loggerCoreData.error("No topic found with topicId: \(topicId)")
                throw ProcessingError.missingRequiredField("Topic not found")
            }
            
            // Decode the arguments to get the new section data
            guard let newReview = self.decodeArguments(arguments: arguments, as: NewTopicOverview.self) else {
                self.loggerOpenAI.error("Couldn't decode arguments for topic review.")
                throw ProcessingError.decodingError("topic review")
            }

            let review = TopicReview(context: context)
            review.reviewId = UUID()
            review.reviewCreatedAt = getCurrentTimeString()
            review.reviewOverview = newReview.overview
            review.overviewGenerated = true
            topic.assignReview(review)
              
          
            // Save the context after processing each section and its questions
           try self.saveCoreDataChanges(context: context, errorDescription: "new topic review")
            
        }
    }
    
    @MainActor
    func processFocusArea(messageText: String, focusArea: FocusArea) async throws {
        let arguments = messageText
        let context = self.dataController.container.viewContext

        try await context.perform {
            
            guard let topic = focusArea.topic else {
                self.loggerOpenAI.log("No topic found for focus area: \(focusArea.focusAreaTitle)")
                throw ProcessingError.missingRequiredField("Related topic not found")
            }
            
            guard let category = topic.category else {
                self.loggerOpenAI.log("No category found for focus area: \(focusArea.focusAreaTitle)")
                throw ProcessingError.missingRequiredField("Related category not found")
            }
            
            // Decode the arguments to get the new section data
            guard let newFocusArea = self.decodeArguments(arguments: arguments, as: NewFocusArea.self) else {
                self.loggerOpenAI.log("Failed to decode new sections for focus area: \(focusArea.focusAreaTitle)")
                throw ProcessingError.decodingError("new focus area sections")
            }
            
            self.processSections(newFocusArea: newFocusArea, focusArea: focusArea, topic: topic, category: category, context: context)
            
            
            try self.saveCoreDataChanges(context: context, errorDescription: "new focus area sections")
            
        }
    }
    
    private func processSections(newFocusArea: NewFocusArea, focusArea: FocusArea, topic: Topic, category: Category, context: NSManagedObjectContext) {
        for newSection in newFocusArea.sections {
            // Skip if section already exists (AI sometimes hallucinates)
            if focusArea.focusAreaSections.contains(where: { $0.sectionNumber == newSection.sectionNumber }) {
                self.loggerOpenAI.log("Skipping duplicate section: \(newSection.sectionNumber)")
                continue
            }
            
            // Create a new section
            let section = createSection(from: newSection, in: context)
            
            // Add new questions to the section
            processQuestions(newSection.questions, for: section, in: context)
            
            // Add relationships
            topic.addToSections(section)
            focusArea.addToSections(section)
            category.addToSections(section)
           
        }
    }
    
    private func createSection(from newSection: NewSection, in context: NSManagedObjectContext) -> Section {
        let section = Section(context: context)
        section.sectionId = UUID()
        section.sectionTitle = newSection.title
        section.sectionNumber = Int16(newSection.sectionNumber)
        return section
    }
    
    private func processQuestions(_ newQuestions: [SectionQuestion], for section: Section, in context: NSManagedObjectContext) {
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
               section.addToQuestions(question)
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
            
//            //mark focus area as complete
//            focusArea.completed = true
//            focusArea.completedAt = getCurrentTimeString()
            
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

//Create new focus area
struct NewTopic: Codable, Hashable {
    let title: String
    let definition: String
    let suggestions: [NewSuggestion]
}

//Create topic overview
struct NewTopicOverview: Codable, Hashable {
    let overview: String
}

//Create topic suggestions
struct NewTopicSuggestions: Codable, Hashable {
    let suggestions: [NewTopicSuggestion]
}

struct NewTopicSuggestion: Codable, Hashable {
    let content: String
    let reasoning: String
    let emoji: String
    let focusArea: NewSuggestion
    
    enum CodingKeys: String, CodingKey {
        case content
        case reasoning
        case emoji
        case focusArea = "focus_area"
    }
    
}

struct NewFocusArea: Codable, Hashable {
    let sections: [NewSection]
}

struct NewSection: Codable, Hashable {
    let title: String
    let sectionNumber: Int
    let questions: [SectionQuestion]
    
    enum CodingKeys: String, CodingKey {
        case title
        case sectionNumber = "section_number"
        case questions
    }
}

//question belongs to a section
struct SectionQuestion: Codable, Hashable {
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
