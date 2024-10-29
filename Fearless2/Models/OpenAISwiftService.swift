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
    func getTranscript(newEntryId: String, data: Data) async -> Result<String?, Error> {
        let fileName = "recording\(newEntryId).m4a"
        let parameters = AudioTranscriptionParameters(fileName: fileName, file: data, responseFormat: "text")

        return await withCheckedContinuation { continuation in
            Task {
                do {
                    let audioObject = try await service.createTranscription(parameters: parameters)
                    continuation.resume(returning: .success(audioObject.text))
                } catch {
                    loggerOpenAI.error("Failed to receive transcript from OpenAI: \(error.localizedDescription)")
                    continuation.resume(returning: .failure(error))
                }
            }
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
        let parameters = SwiftOpenAI.MessageParameter(role: .user, content: content)
        
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
    func processSections(category: String, topicId: UUID) async {
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
                guard let newContextQuestions = self.decodeArguments(arguments: arguments, as: QuestionsContext.self) else {
                    self.loggerOpenAI.error("Couldn't decode arguments for sections.")
                    return
                }
                
                topic.topicTitle = newContextQuestions.title

                // Loop through the new sections and save them to CoreData, attaching them to the topic
                for newSection in newContextQuestions.sections {
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
                        topic.addToQuestions(question)
                    }

                    // Add the section to the topic
                    topic.addToSections(section)
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
    func processSectionSummary(category: String, section: Section) async {
        let arguments = self.messageText
        let context = self.dataController.container.viewContext

        await context.perform {
            // Decode the arguments to get the new topic data
            guard let newSummary = self.decodeArguments(arguments: arguments, as: SectionSummary.self) else {
                self.loggerOpenAI.error("Couldn't decode arguments for topic.")
                return
            }
            
            //create entry
            let entry: Entry
            entry = Entry(context: context)
            entry.entryId = UUID()
            entry.entryCreatedAt = getCurrentTimeString()
            entry.entrySummary = newSummary.summary
            entry.entryFeedback = newSummary.feedback
            section.assignEntry(entry)
            
            //Update entry insights
            for newInsight in newSummary.insights {
                let insight = Insight(context: context)
                insight.insightId = UUID()
                insight.insightContent = newInsight.content
                entry.addToInsights(insight)
            }
            
            //Save the context
            do {
                try context.save()
            } catch {
                self.loggerCoreData.error("Error saving topic: \(error.localizedDescription)")
            }
        }
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

//Create new section
struct QuestionsContext: Codable, Hashable {
    let title: String
    let sections: [SectionOfQuestions]
}

struct SectionOfQuestions: Codable, Hashable {
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
struct SectionSummary: Codable, Hashable {
    let summary: String
    let feedback: String
    let insights: [NewInsight]
}

//insight
struct NewInsight: Codable, Hashable {
    let content: String
}

