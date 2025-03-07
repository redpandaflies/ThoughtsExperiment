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
    @Published var onboardingCategory: Category? = nil
    
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
    
    
    
    //MARK: other
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
    
    //mark section as complete
    func completeSection(section: Section) async {
        await context.perform {
            section.completed = true
        }
        
        await self.save()
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
                    let arrayString = answer.joined(separator: ";")
                    question.questionAnswerSingleSelect = arrayString
                }
            case .multiSelect:
                if let answer = userAnswer as? [String] {
                    let arrayString = answer.joined(separator: ";")
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
    
    //save answer onboarding
    func saveAnswerOnboarding(questionType: QuestionType, question: QuestionsNewCategory, userAnswer: Any, categoryLifeArea: String) async {
        await context.perform {
            // create a new question
            let newQuestion = Question(context: self.context)
            newQuestion.questionId = UUID()
            newQuestion.createdAt = getCurrentTimeString()
            newQuestion.questionType = questionType.rawValue
            self.logger.info("Question type being saved: \(newQuestion.questionType)")
            newQuestion.questionContent = question.content
            newQuestion.categoryStarter = true
            
            // set the answer based on the question type
            switch questionType {
            case .open:
                if let answer = userAnswer as? String {
                    newQuestion.questionAnswerOpen = answer
                }
            case .singleSelect:
                if let answer = userAnswer as? String {
                    newQuestion.questionAnswerSingleSelect = answer
                }
            case .multiSelect:
                if let answer = userAnswer as? [String] {
                    let arrayString = answer.joined(separator: ";")
                    newQuestion.questionAnswerMultiSelect = arrayString
                }
            }
            
            // Mark the question as completed
            newQuestion.completed = true
            
            // find the Category
            
            if let category = self.onboardingCategory {
                category.addToQuestions(newQuestion)
            } else {
                let categoryRequest = NSFetchRequest<Category>(entityName: "Category")
                categoryRequest.predicate = NSPredicate(format: "lifeArea == %@", categoryLifeArea)
                
                do {
                    let categories = try self.context.fetch(categoryRequest)
                    if let fetchedCategory = categories.first {
                        
                        // add question to the category
                        fetchedCategory.addToQuestions(newQuestion)
                        self.onboardingCategory = fetchedCategory
                        
                    } else {
                        self.logger.error("No category found with lifeArea: \(categoryLifeArea)")
                    }
                } catch {
                    self.logger.error("Error fetching category: \(error.localizedDescription)")
                }
            }
        }
        
        await self.save()
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
    
    
    
    //delete all suggestions
    func deleteTopicSuggestions(topicId: UUID) async throws -> Topic? {
        
        let request = NSFetchRequest<Topic>(entityName: "Topic")
        request.predicate = NSPredicate(format: "id == %@", topicId as CVarArg)
       
        var topic: Topic? = nil
        
        try await context.perform {
            do {
                
                guard let fetchedTopic = try self.context.fetch(request).first else { return }
                
                let topicSuggestions = fetchedTopic.topicSuggestions
               
                for item in topicSuggestions {
                    self.context.delete(item)
                }
               
                Task {
                    await self.save()
                }
                
                topic = fetchedTopic
                
            } catch {
                self.logger.error("Failed to batch delete suggestions: \(error.localizedDescription), \(error)")
                throw CoreDataError.coreDataError(error)
            }
           
        }
        return topic
    }
    
    func updateOverviewStatus(review: TopicReview) async {
        await context.perform {
            review.overviewGenerated.toggle()
            
            Task {
                await self.save()
            }
        }
        
    }
    
}

//MARK: Topic related functions
extension DataController {
    
    //create new topic
    func createTopic(suggestion: NewTopicSuggestion, category: Category) async -> (topicId: UUID?, focusArea: FocusArea?) {
        var topicId: UUID? = nil
        var createdFocusArea: FocusArea? = nil
        
        await context.perform {
            
            let topic = Topic(context: self.context)
            topic.topicId = UUID()
            topic.topicCreatedAt = getCurrentTimeString()
            topic.topicStatus = TopicStatusItem.active.rawValue
            topic.topicTitle = suggestion.content
            let highestFocusAreaTopic = category.categoryTopics.max(by: { $0.focusAreasLimit < $1.focusAreasLimit })

           //get the limit for the topic with highest focusAreasLimit, this is used instead of a simple category.categoryTopics.count because topics can be deleted
            let highestFocusAreasLimit = highestFocusAreaTopic?.focusAreasLimit ?? 0
            
            topic.focusAreasLimit = Int16(highestFocusAreasLimit + 1)
            category.addToTopics(topic)
            
            
            let focusArea = FocusArea(context: self.context)
            focusArea.focusAreaId = UUID()
            focusArea.focusAreaCreatedAt = getCurrentTimeString()
            focusArea.focusAreaTitle = suggestion.focusArea.content
            focusArea.focusAreaReasoning = suggestion.focusArea.reasoning
            focusArea.focusAreaEmoji = suggestion.focusArea.emoji
            topic.addToFocusAreas(focusArea)
            category.addToFocusAreas(focusArea)
            
            topicId = topic.topicId
            createdFocusArea = focusArea
            self.newTopic = topic
            self.logger.log("Updated newTopic published variable")
        }
        
        await self.save()
        
        return (topicId, createdFocusArea)
    }
    
    func updateTopicStatus(id: UUID, item: TopicStatusItem) async {
        let request = NSFetchRequest<Topic>(entityName: "Topic")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        await context.perform {
            do {
                let fetchedTopic = try self.context.fetch(request)
                
                if let topic = fetchedTopic.first {
                    topic.topicStatus = item.rawValue
                    
                    Task {
                        await self.save()
                    }
                    
                    //reset newTopic so that new topic creation flow functions properly
                    if let _ = self.newTopic {
                        self.newTopic = nil
                    }
                }
                
            } catch {
                self.logger.error("Failed to update topic status: \(error.localizedDescription)")
            }
            
        }
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
    
    //delete all
    func deleteAll() async {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // Configure batch to get object IDs for updating the context's state
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        await context.perform {
            do {
                // Execute the batch delete
                let batchDelete = try self.context.execute(batchDeleteRequest) as? NSBatchDeleteResult
                
                // Use the deleted object IDs to update the context's state
                if let deletedObjectIDs = batchDelete?.result as? [NSManagedObjectID] {
                    let changes = [NSDeletedObjectsKey: deletedObjectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.context])
                }
                
                // Save context to ensure changes are persisted
                try self.context.save()
                
                self.logger.info("Successfully deleted all categories")
            } catch {
                self.logger.error("Error batch deleting all categories: \(error.localizedDescription)")
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
            
            if let currentCategory = currentTopic.category {
                self.logger.log("Adding focus area to category")
                currentCategory.addToFocusAreas(newFocusArea)
            }
            
            
            self.logger.log("Created new focus area")
            focusArea = newFocusArea
            
            //get total number of focus areas
            totalFocusAreas = currentTopic.topicFocusAreas.count
            
        }
        
        await self.save()
        
        if let focusAreasCount = totalFocusAreas {
            await MainActor.run {
                self.newFocusArea = focusAreasCount - 1
            }
        }
        
        
        return focusArea
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
                        
                        //don't use topic.topicId because topic has been deleted already
                        let topicId = id.uuidString
                        
                        await self.deleteTopicImage(topicId: topicId)
                    }
                    
                    //reset newTopic so that new topic creation flow functions properly
                    if let _ = self.newTopic {
                        self.newTopic = nil
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
    
    //save topic image
    func saveTopicImage(topic: Topic, imageURL: String) async {
        
        context.performAndWait {
            
            topic.topicMainImage = imageURL
            
            Task {
                await self.save()
            }
            
        }
    }
    

    func addEndOfTopicFocusArea(topic: Topic) async {
        
        await context.perform {
            let fetchEndOfTopic = topic.topicFocusAreas.filter {$0.endOfTopic == true}
            guard let category = topic.category else {
                self.logger.error("Failed to add end of topic focus area. Category not found")
                return
            }
            
            if fetchEndOfTopic.isEmpty {
                let newFocusArea = FocusArea(context: self.context)
                newFocusArea.focusAreaId = UUID()
                newFocusArea.focusAreaCreatedAt = getCurrentTimeString()
                newFocusArea.focusAreaTitle = EndOfTopic.sampleEndOfTopic.title
                newFocusArea.focusAreaReasoning = EndOfTopic.sampleEndOfTopic.reasoning
                newFocusArea.endOfTopic = true
                topic.addToFocusAreas(newFocusArea)
                category.addToFocusAreas(newFocusArea)
                
                for section in EndOfTopic.sampleEndOfTopic.sections {
                    let newSection = Section(context: self.context)
                    newSection.sectionId = UUID()
                    newSection.sectionNumber = Int16(section.sectionNumber)
                    newSection.sectionTitle = section.title
                    topic.addToSections(newSection)
                    newFocusArea.addToSections(newSection)
                    category.addToFocusAreas(newFocusArea)
                    
                }
            }
        }
        
        await self.save()
        
        await MainActor.run {
            self.newFocusArea = topic.topicFocusAreas.count - 1
        }
    }
    
    //mark topic and section as complete
    func completeTopic(topic: Topic, section: Section) async {
        await context.perform {
            section.completed = true
            topic.completed = true
        }
        
        await self.save()
    }
}

//MARK: category (realms)

extension DataController {
    

    func addCategoriesToCoreData() async {
    
        let request = NSFetchRequest<Category>(entityName: "Category")
        await context.perform {
            do {
                let results = try self.context.fetch(request)
                let count = results.count
                guard count == 0 else {
                    self.logger.info("Categories already exist in CoreData.")
                    return
                }
                
                // Populate CoreData with sample realms
                for realm in Realm.realmsData {
                    let category = Category(context: self.context)
                    category.categoryId = UUID()
                    category.orderIndex = Int16(realm.orderIndex)
                    category.categoryEmoji = realm.emoji
                    category.categoryName = realm.name
                    category.categoryLifeArea = realm.lifeArea
                    category.categoryUndiscovered = realm.undiscoveredDescription
                    category.categoryDiscovered = realm.discoveredDescription
                }
                
            } catch {
                self.logger.error("Error checking/populating CoreData: \(error)")
            }
        }
        
        await self.save()
        
    }
    
    /// Creates a single category in CoreData based on the provided life area option
    /// - Parameter lifeAreaOption: The life area string to match with Realm data
    /// - Returns: The created Category entity or nil if not found
    func createSingleCategory(lifeArea: String) async {
        
        // Find the matching realm data
        guard let realmData = QuestionCategory.getCategoryData(for: lifeArea) else {
            self.logger.error("No matching realm found for lifeArea: \(lifeArea)")
            return
        }
        
        await context.perform {
            do {
                // Check if this category already exists
                let request = NSFetchRequest<Category>(entityName: "Category")
                let allCategories = try self.context.fetch(request)
                                
                let matchingCategories = allCategories.filter { category in
                    category.lifeArea == lifeArea
                }
                                
                if !matchingCategories.isEmpty {
                    self.logger.info("Category already exists for \(lifeArea)")
                    return
                }
                
                // Create the new category
                let category = Category(context: self.context)
                category.categoryId = UUID()
                category.orderIndex = Int16(allCategories.count)
                category.categoryCreatedAt = getCurrentTimeString()
                category.categoryEmoji = realmData.emoji
                category.categoryName = realmData.name
                category.categoryLifeArea = realmData.lifeArea
                category.categoryUndiscovered = realmData.undiscoveredDescription
                category.categoryDiscovered = realmData.discoveredDescription
                
            } catch {
                self.logger.error("Error creating single category: \(error)")
            }
        }
        
        await self.save()
    }

    /// Saves all categories from Realm.realmsData except for the one that already exists in CoreData
    /// - Parameter existingLifeArea: The life area of the category that should be skipped
    func saveAllCategoriesExceptExisting(existingLifeArea: String) async {
        await context.perform {
            do {
                // Check which categories already exist
                let request = NSFetchRequest<Category>(entityName: "Category")
                let existingCategories = try self.context.fetch(request)
                let existingLifeAreas = existingCategories.compactMap { $0.categoryLifeArea }
                
                // Filter realms that need to be created
                let realmsToCreate = Realm.realmsData.filter { realm in
                    !existingLifeAreas.contains(realm.lifeArea)
                }
                
                // Create each category that doesn't exist yet
                for realm in realmsToCreate {
                    let category = Category(context: self.context)
                    category.categoryId = UUID()
                    category.orderIndex = Int16(realm.orderIndex)
                    category.categoryCreatedAt = getCurrentTimeString()
                    category.categoryEmoji = realm.emoji
                    category.categoryName = realm.name
                    category.categoryLifeArea = realm.lifeArea
                    category.categoryUndiscovered = realm.undiscoveredDescription
                    category.categoryDiscovered = realm.discoveredDescription
                    
                    self.logger.info("Created category: \(realm.name)")
                }
                
                self.logger.info("Created \(realmsToCreate.count) additional categories")
            } catch {
                self.logger.error("Error saving additional categories: \(error)")
            }
        }
        
        await self.save()
    }
    
    func removeDuplicateCategories() async {
        let request = NSFetchRequest<Category>(entityName: "Category")
        
        await context.perform {
            do {
                let categories = try self.context.fetch(request)
                
                // Create a dictionary to track unique category names
                var uniqueCategories: [String: Category] = [:]
                var duplicatesToDelete: [Category] = []
                
                // Identify duplicates - keeping the first occurrence of each name
                for category in categories {
                    let name = category.categoryName
                    
                    if uniqueCategories[name] == nil {
                        // Keep the first instance
                        uniqueCategories[name] = category
                    } else {
                        // Mark subsequent instances for deletion
                        duplicatesToDelete.append(category)
                    }
                }
                
                // Log the duplicates found
                self.logger.info("Found \(duplicatesToDelete.count) duplicate categories to remove")
                
                // Delete the duplicates
                for duplicate in duplicatesToDelete {
                    self.logger.debug("Removing duplicate category: \(duplicate.categoryName)")
                    self.context.delete(duplicate)
                }
                
                // Save if there were duplicates removed
                if !duplicatesToDelete.isEmpty {
                    try self.context.save()
                    self.logger.info("Successfully removed duplicate categories")
                }
                
            } catch {
                self.logger.error("Error removing duplicate categories: \(error)")
            }
        }
    }
    
    func updatePoints(newPoints: Int) async {
        let request = NSFetchRequest<Points>(entityName: "Points")
        
        await context.perform {
            do {
                let results = try self.context.fetch(request)
                if let existingPoints = results.first {
                    existingPoints.total += Int64(newPoints)
                } else {
                    let points = Points(context: self.context)
                    points.pointsId = UUID()
                    points.total = Int64(newPoints)
                }
                
            } catch {
                self.logger.error("Error updating points CoreData: \(error)")
            }
        }
        
        await self.save()
        
    }
    
    func resetPoints() async {
        let request = NSFetchRequest<Points>(entityName: "Points")
        
        await context.perform {
            do {
                let results = try self.context.fetch(request)
                if let existingPoints = results.first {
                    existingPoints.total = 0
                }
                
            } catch {
                self.logger.error("Error updating points CoreData: \(error)")
            }
        }
        
        await self.save()
        
    }
    
}

