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
    
    @Published var messageText: String = ""
    var functionContent: String = ""
    var runId: String = ""
    var toolCallId: String = ""
    
    let loggerOpenAI = Logger.openAIEvents
    let loggerCoreData = Logger.coreDataEvents
    
    private let openAIPartialKey = Constants.openAIPartialKey
    private var service: SwiftOpenAI.OpenAIService
    private var dataController: DataController
    
    enum OpenAIError: Error {
        case retrievalFailed
        case runIncomplete
    }
    
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
            
            return thread.id
        } catch {
            loggerOpenAI.error("Failed to create thread: \(error.localizedDescription)")
            return nil
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
            loggerOpenAI.error("Error when creating the message: \(error.localizedDescription)")
            return nil
        }
        
    }
    
    func createRunAndStreamMessage(threadId: String, selectedAssistant: AssistantItem) async throws {
        await MainActor.run {
            self.functionContent = ""
            self.toolCallId = ""
            self.messageText = ""
            
        }
       
        guard let selectedAssistantId = selectedAssistant.getAssistantId() else {
            loggerOpenAI.error("Assistant ID missing.")
            return
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
                            await MainActor.run {
                                if !textContent.text.value.isEmpty {
                                    self.messageText += textContent.text.value
                                    loggerOpenAI.log("messageText: \(self.messageText)")
                                }
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
                        
                        
                    case .done, .error:
                    
                        loggerOpenAI.log("Stream complete or ran into error")
                        break
                    
                    default:
                        continue
                }
            }
        }  catch {
            loggerOpenAI.error("Error when streaming run: \(error.localizedDescription)")
            throw OpenAIError.runIncomplete // End the loop in the event of an error
        }
        
    }
    
    //cancel run
    func cancelRun(threadId: String) async throws {
        do {
            let run = try await service.cancelRun(threadID: threadId, runID: self.runId)
            loggerOpenAI.info("Successfully cancelled run: \(run.id)")
            
        } catch {
            loggerOpenAI.error("Failed to cancel run: \(error.localizedDescription)")
        }
        
    }
    
}

//process data
extension OpenAISwiftService {
    
    private func decodeArguments<T: Decodable>(arguments: String, as type: T.Type) -> T? {
        guard let data = arguments.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    @MainActor
    func processNewTopic(topicId: UUID) async {
        let arguments = self.messageText
        let context = self.dataController.container.viewContext

        await context.perform {
            // Fetch the topic with the provided topicId
            let request = NSFetchRequest<Topic>(entityName: "Topic")
            request.predicate = NSPredicate(format: "id == %@", topicId as CVarArg)

            do {
                guard let topic = try context.fetch(request).first else {
                    self.loggerCoreData.error("No topic found with topicId: \(topicId)")
                    return
                }

                // Decode the arguments to get the new section data
                guard let newTopic = self.decodeArguments(arguments: arguments, as: NewTopic.self) else {
                    self.loggerOpenAI.error("Couldn't decode arguments for sections.")
                    return
                }
                
                if topic.topicTitle.isEmpty {
                    topic.topicTitle = newTopic.topicTitle
                }
                
                let focusArea = FocusArea(context: context)
                focusArea.focusAreaId = UUID()
                focusArea.createdAt = getCurrentTimeString()
                focusArea.focusAreaTitle = newTopic.focusArea.title
                focusArea.focusAreaReasoning = newTopic.focusArea.reasoning
                topic.addToFocusAreas(focusArea)
                
                // Loop through the new sections and save them to CoreData, attaching them to the topic
                for newSection in newTopic.sections {
                    //check if the section number already exists, if not, add the section (AI sometimes hallucinates)
                    
                    if focusArea.focusAreaSections.contains(where: { $0.sectionNumber == newSection.sectionNumber }) {
                        continue
                    }
                    
                    // Create a new section
                    let section = Section(context: context)
                    section.sectionId = UUID()
                    section.sectionTitle = newSection.title
                    section.sectionNumber = Int16(newSection.sectionNumber)
                   
                    
                    // Add new questions to the section
                    for newQuestion in newSection.questions {
                        let question = Question(context: context)
                        question.questionId = UUID()
                        question.questionContent = newQuestion.content
                        question.questionType = newQuestion.questionType.rawValue
                        
                        if newQuestion.questionType == .scale {
                            question.questionMinLabel = newQuestion.minLabel
                            question.questionMaxLabel = newQuestion.maxLabel
                        } else if newQuestion.questionType == .multiSelect {
                            question.questionMultiSelectOptions = newQuestion.options.map {$0.text}.joined(separator: ",")
                            
                        }

                        // Add the question to the section
                        section.addToQuestions(question)
                    }

                    // Add the section to the topic & focus area
                    focusArea.addToSections(section)
                }

              
            } catch {
                self.loggerCoreData.error("Error fetching topic: \(error.localizedDescription)")
            }
            
            // Save the context after processing each section and its questions
            do {
                try context.save()
            } catch {
                self.loggerCoreData.error("Error saving section: \(error.localizedDescription)")
            }
        }
    }
    
    //save new entry to CoreData
    //need entryId, so we know which entry AND topic is being updated
    @MainActor
    func processSectionSummary(section: Section) async {
        let arguments = self.messageText
        let context = self.dataController.container.viewContext

        await context.perform {
            // Decode the arguments to get the new topic data
            guard let newSummary = self.decodeArguments(arguments: arguments, as: NewSectionSummary.self) else {
                self.loggerOpenAI.error("Couldn't decode arguments for section summary.")
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
            
            //Update entry insights
            for newInsight in newSummary.insights {
                let insight = Insight(context: context)
                insight.insightId = UUID()
                insight.insightContent = newInsight.content
                summary.addToInsights(insight)
            }
            
            //Save the context
            do {
                try context.save()
            } catch {
                self.loggerCoreData.error("Error saving topic: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func processEntry(entryId: UUID) async -> Entry? {
        let arguments = self.messageText
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
    func processSectionSuggestions() async -> [String]? {
        let arguments = self.messageText
        
        guard let newSuggestions = self.decodeArguments(arguments: arguments, as: NewSectionSuggestions.self) else {
            self.loggerOpenAI.error("Couldn't decode arguments for section suggestions.")
            return nil
        }
        
        var suggestions: [String] = []
        
        for item in newSuggestions.suggestions {
            suggestions.append(item.content)
        }
        
        return suggestions
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
    let topicTitle: String
    let focusArea: NewFocusArea
    let sections: [NewSection]
    
    enum CodingKeys: String, CodingKey {
        case topicTitle = "topic_title"
        case focusArea = "focus_area"
        case sections
    }
}

struct NewFocusArea: Codable, Hashable {
    let title: String
    let reasoning: String
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
    let questionType: QuestionType
    let options: [Option]
    let minLabel: String
    let maxLabel: String
    
    enum CodingKeys: String, CodingKey {
        case content
        case questionType = "question_type"
        case options
        case minLabel
        case maxLabel
    }
}

enum QuestionType: String, Codable {
    case open
    case multiSelect
    case scale
}

struct Option: Codable, Hashable {
    let text: String
}

//process update to topic
struct NewSectionSummary: Codable, Hashable {
    let summary: String
    let feedback: String
    let insights: [NewInsight]
}

//insight
struct NewInsight: Codable, Hashable {
    let content: String
}

//section suggestions
struct NewSectionSuggestions: Codable, Hashable {
    let suggestions: [SectionSuggestion]
}

struct SectionSuggestion: Codable, Hashable {
    let content: String
}

//entry

struct NewEntry: Codable, Hashable {
    let title: String
    let summary: String
    let feedback: String
    let insights: [NewInsight]
}
