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
    
    //save new entry to CoreData
    @MainActor
    func processTopic(category: String, topicId: UUID? = nil) async {
        let arguments = self.functionContent
        let context = self.dataController.container.viewContext

        await context.perform {
            // Decode the arguments to get the new topic data
            guard let newTopic = self.decodeArguments(arguments: arguments, as: NewTopic.self) else {
                self.loggerOpenAI.error("Couldn't decode arguments for topic.")
                return
            }

            let topic: Topic

            if let topicId = topicId {
                // `topicId` is provided, attempt to fetch existing Topic
                let request = NSFetchRequest<Topic>(entityName: "Topic")
                request.predicate = NSPredicate(format: "id == %@", topicId as CVarArg)

                do {
                    let fetchedTopics = try context.fetch(request)
                    if let savedTopic = fetchedTopics.first {
                        // Existing Topic found, use it
                        topic = savedTopic
                        
                    } else {
                        // No existing Topic found, create a new one
                        topic = Topic(context: context)
                        topic.topicId = UUID()
                        topic.topicCreatedAt = getCurrentTimeString()
                    }
                } catch {
                    self.loggerCoreData.error("Error fetching topic: \(error.localizedDescription)")
                    return
                }
            } else {
                // `topicId` is nil, create a new Topic
                topic = Topic(context: context)
                topic.topicId = UUID()
                topic.topicCreatedAt = getCurrentTimeString()
                topic.topicCategory = category
                topic.topicTitle = newTopic.title
            }

            // Update topic properties with data from `newTopic`
            topic.topicSummary = newTopic.summary
            topic.topicFeedback = newTopic.feedback

            // Remove existing questions if updating an existing Topic
            if let existingQuestions = topic.questions as? Set<Question>, !existingQuestions.isEmpty {
                for question in existingQuestions {
                    context.delete(question)
                }
                // Save the context after deleting existing questions
                do {
                    try context.save()
                } catch {
                    self.loggerCoreData.error("Error saving after deleting questions: \(error.localizedDescription)")
                    return
                }
            }

            // Add new questions from `newTopic`
            for newQuestion in newTopic.questions {
                let question = Question(context: context)
                question.questionId = UUID()
                question.questionContent = newQuestion.content
                question.questionEmoji = newQuestion.emoji
                topic.addToQuestions(question)
            }

            // Save the context
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

struct NewTopic: Codable, Hashable {
    let title: String
    let summary: String
    let feedback: String
    let questions: [NewQuestion]
}

struct NewQuestion: Codable, Hashable {
    let content: String
    let emoji: String
}
