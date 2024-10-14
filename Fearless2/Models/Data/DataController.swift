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

    let container: NSPersistentCloudKitContainer
    var context: NSManagedObjectContext
    let logger = Logger.coreDataEvents
    
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
    func createTopic(userAnswer: String) async {
        await context.perform {
            let topic = Topic(context: self.context)
            topic.topicId = UUID()
            topic.topicUserDescription = userAnswer
            self.newTopic = topic
        }
        await self.save()
        
        
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
    
    //save user answer for a rating scale question
    func saveScaleAnswer(question: String, userAnswer: Double) async {
        
        await context.perform {
            let newQuestion = Question(context: self.context)
            newQuestion.questionId = UUID()
            newQuestion.questionType = "scale"
            newQuestion.questionContent = question
            newQuestion.answerScale = userAnswer
            if let topic = self.newTopic {
                topic.addToQuestions(newQuestion)
            }
        }
        await self.save()
        
    }
    
    //save user answer for a multi-select question
    func saveMultiSelectAnswer(question: String, userAnswers: [String]) async {
        let arrayString = userAnswers.joined(separator: ",")
        
        await context.perform {
            let newQuestion = Question(context: self.context)
            newQuestion.questionId = UUID()
            newQuestion.questionType = "multi-select"
            newQuestion.questionContent = question
            newQuestion.questionAnswerMultiSelect = arrayString
            if let topic = self.newTopic {
                topic.addToQuestions(newQuestion)
            }
            
        }
    }
    
    //delete topic
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
                    }
                }
                    
            } catch {
                self.logger.error("Failed to delete topic from Core Data: \(error.localizedDescription)")
            }
        }
    }
    
}
