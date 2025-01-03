//
//  DataController.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import CoreData
import Foundation
import OSLog


final class DataController: ObservableObject {
    
    @Published var newTopic: Topic? = nil
    @Published var newFocusArea: Int = 0
    @Published var allSectionsComplete: Bool = false //to manage when section recap gets unlocked

    let container: NSPersistentCloudKitContainer
    var context: NSManagedObjectContext
    let logger = Logger.coreDataEvents
    
    private var fileManager = LocalFileManager.instance
    private let imageCacheManager = ImageCacheManager.instance
    private var saveTask: Task<Void, Error>?
    
    init(inMemory: Bool = false) {
        self.container = NSPersistentCloudKitContainer(name: "ModelTopics")
        self.context = container.viewContext
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        //merge policy
        self.context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        self.container.loadPersistentStores { storeDescription, error in
            if let error {
                self.logger.error("Error loading store: \(error.localizedDescription)")
            }
            
        }
        self.context.automaticallyMergesChangesFromParent = true
    }
    
    //save only if there are changes
    func save() async {
        await context.perform {
            if self.context.hasChanges {
                do {
                    try self.context.save()
                    
                } catch {
                    self.logger.error("Failed to save to Core Data: \(error.localizedDescription)")
                }
                
            }
        }
    }
    
    //create new topic
    func createTopic() async {
        await context.perform {
            if let topic = self.newTopic {
                self.logger.log("Topic already exists")
            } else {
                
                let topic = Topic(context: self.context)
                topic.topicId = UUID()
                topic.topicCreatedAt = getCurrentTimeString()
                
                self.newTopic = topic
                self.logger.log("Updated newTopic published variable")
            }
           
        }
       
    }
    
    //create new topic
    func createFocusArea(suggestion: any SuggestionProtocol, topic: Topic?) async -> FocusArea? {
        
        var focusArea: FocusArea?
        var totalFocusAreas: Int?

        await context.perform {
            let newFocusArea = FocusArea(context: self.context)
            newFocusArea.focusAreaId = UUID()
            newFocusArea.focusAreaCreatedAt = getCurrentTimeString()
            newFocusArea.focusAreaTitle = suggestion.title
            newFocusArea.focusAreaEmoji = suggestion.symbol
            newFocusArea.focusAreaReasoning = suggestion.suggestionDescription
            
            guard let currentTopic = topic else {
                self.logger.log("Topic not found, unable to create new focus area")
                return
            }
            
            currentTopic.addToFocusAreas(newFocusArea)
          

            self.logger.log("Created new focus area")
            focusArea = newFocusArea
            
            //get total number of focus areas
            totalFocusAreas = currentTopic.focusAreas?.count
        
        }
        
        await self.save()
        
        if let focusAreasCount = totalFocusAreas {
            await MainActor.run {
                newFocusArea = focusAreasCount - 1
            }
        }
        
        
        return focusArea
    }
    
    //fetch a topic
    func fetchTopic(id: UUID) async -> Topic? {
        let request = NSFetchRequest<Topic>(entityName: "Topic")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        var fetchedTopic: Topic? = nil
        
        await context.perform {
            do {
                let results = try self.context.fetch(request)
                if let topic = results.first {
                    
                    fetchedTopic = topic
                }
            } catch {
                self.logger.error("Error fetching entry with ID \(id): \(error.localizedDescription)")
               
            }
        }
        
        return fetchedTopic
        
    }
    
    //fetch all topics
    func fetchAllTopics() async -> [Topic] {
        let request = NSFetchRequest<Topic>(entityName: "Topic")
        
        var fetchedTopics: [Topic] = []
        
        await context.perform {
            do {
                fetchedTopics = try self.context.fetch(request)
            } catch {
                self.logger.error("Error fetching all topics: \(error.localizedDescription)")
            }
        }
        
        return fetchedTopics
    }
    
    //fetch a section
    func fetchSection(id: UUID) async -> Section? {
        let request = NSFetchRequest<Section>(entityName: "Section")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        var fetchedSection: Section? = nil
        
        await context.perform {
            do {
                let results = try self.context.fetch(request)
                if let section = results.first {
                    
                    fetchedSection = section
                }
            } catch {
                self.logger.error("Error fetching entry with ID \(id): \(error.localizedDescription)")
               
            }
        }
        
        return fetchedSection
        
    }
    
    //save user answer for an question
    //note: questionContent needed when creating new topic, questionId needed when updating topic
    func saveAnswer(questionType: QuestionType, questionContent: String? = nil, questionId: UUID? = nil, userAnswer: Any) async {
        await context.perform {
            let question: Question
            
            if let id = questionId {
                // Fetch the existing question by ID
                let request = NSFetchRequest<Question>(entityName: "Question")
                request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                
                do {
                    let fetchedQuestions = try self.context.fetch(request)
                    if let savedQuestion = fetchedQuestions.first {
                        question = savedQuestion
                    } else {
                        self.logger.error("No question found with ID: \(id)")
                        return
                    }
                } catch {
                    self.logger.error("Error fetching question: \(error.localizedDescription)")
                    return
                }
            } else {
                // Create a new question if no `questionId` is provided
                question = Question(context: self.context)
                question.questionId = UUID()
                question.createdAt = getCurrentTimeString()
                question.questionType = questionType.rawValue
                if let content = questionContent {
                    question.questionContent = content
                    question.starterQuestion = true
                }
                if let topic = self.newTopic {
                    self.logger.log("Adding new \(questionType.rawValue) question to topic \(topic.topicId.uuidString)")
                    topic.addToQuestions(question)
                }
            }
            
            // Set the answer based on the question type
            switch questionType {
            case .open:
                if let answer = userAnswer as? String {
                    question.questionAnswerOpen = answer
                }
            case .singleSelect:
                if let answer = userAnswer as? [String] {
                    let arrayString = answer.joined(separator: ",")
                    question.questionSingleSelectOptions = arrayString
                }
            case .multiSelect:
                if let answer = userAnswer as? [String] {
                    let arrayString = answer.joined(separator: ",")
                    question.questionAnswerMultiSelect = arrayString
                }
            }

            // Mark the question as completed if it's not already
            if !question.completed {
                question.completed = true
            }
        }

//        // Save the context
//        await self.save()
    }
    
    //delete topic
    @MainActor
    func deleteTopic(id: UUID) async {
        
        let request = NSFetchRequest<Topic>(entityName: "Topic")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        await context.perform {
            do {
                let fetchedTopic = try self.context.fetch(request)
                
                if let topic = fetchedTopic.first {
                    self.context.delete(topic)
                    
                    Task {
                        await self.save()
                        
                        //don't use topic.topicId because topic has been deleted already
                        let topicId = id.uuidString
                        
                        await self.deleteTopicImage(topicId: topicId)
                    }
                }
                    
            } catch {
                self.logger.error("Failed to delete topic from Core Data: \(error.localizedDescription)")
            }

        }
 
    }
    
    private func deleteTopicImage(topicId: String) async {
        let folderName = "topic_images"
      
        imageCacheManager.deleteImage(key: topicId)
        fileManager.deleteImage(imageId: topicId, folderName: folderName)
    }
    
    func deleteEntry(id: UUID) async {
        
        let request = NSFetchRequest<Entry>(entityName: "Entry")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        await context.perform {
            do {
                let fetchedTopic = try self.context.fetch(request)
                
                if let entry = fetchedTopic.first {
                    self.context.delete(entry)
                    
                    Task {
                        await self.save()
                    }
                }
                    
            } catch {
                self.logger.error("Failed to delete entry from Core Data: \(error.localizedDescription)")
            }
        }
    }
    
    //save topic image
    @MainActor
    func saveTopicImage(topic: Topic, imageURL: String) async {
       
        context.performAndWait {
           
            topic.topicMainImage = imageURL
            
            Task {
               await self.save()
            }
            
        }
        
    }
    
}


