//
//  TopicRepository.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/5/25.
//
import CoreData
import Foundation
import OSLog

final class TopicRepository {
    private let context: NSManagedObjectContext
    private let logger = Logger.coreDataEvents
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchTopic(id: UUID) async -> Topic? {
        let request = NSFetchRequest<Topic>(entityName: "Topic")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return await context.perform {
            do {
                return try self.context.fetch(request).first
            } catch {
                self.logger.error("Error fetching topic: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func fetchDailyTopic(id: UUID) async -> TopicDaily? {
        let request = NSFetchRequest<TopicDaily>(entityName: "TopicDaily")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        return await context.perform {
            do {
                return try self.context.fetch(request).first
            } catch {
                self.logger.error("Error fetching topic: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func fetchAllDailyTopics() async -> [TopicDaily]? {
        let request = NSFetchRequest<TopicDaily>(entityName: "TopicDaily")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        var topics: [TopicDaily] = []
        
       await context.perform {
            do {
                topics = try self.context.fetch(request)
            } catch {
                self.logger.error("Error fetching all TopicDaily objects: \(error.localizedDescription)")
                
            }
        }
        
        return topics
    }

}
