//
//  DataController.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import CoreData
import Foundation
import OSLog
import SwiftUI


final class DataController: ObservableObject {
    
    @Published var newTopic: Topic? = nil
    @Published var newFocusArea: Bool = false
    @Published var onboardingCategory: Category? = nil
    @Published var deletedAllData: Bool = false
    
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
    
    // save only if there are changes
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
    
}

//MARK: Topic related functions
extension DataController {
    
    //create new topics based on quest map
    func createTopics(questMap: [QuestMapItem], category: Category) async {
        
        await context.perform {
            
            for quest in questMap {
                let topic = Topic(context: self.context)
                topic.topicId = UUID()
                topic.topicCreatedAt = getCurrentTimeString()
                topic.topicStatus = TopicStatusItem.locked.rawValue
                topic.topicQuestType = quest.questType.rawValue
                topic.orderIndex = Int16(quest.orderIndex)
                
                //add topic to category
                category.addToTopics(topic)
                self.logger.log("added new quest: \(quest.orderIndex) \(quest.questType.rawValue)")
            }
            
        }
        
        await self.save()
        
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
    
    
    
    //create new topic
    func createFocusArea(suggestion: any SuggestionProtocol, topic: Topic?) async -> FocusArea? {
        
        var focusArea: FocusArea?
        
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
            
        }
        
        await self.save()

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
            
            if let existingFocusArea = fetchEndOfTopic.first {
                
                self.logger.log("Adding end of topic path sections")
                
                for section in EndOfTopic.sampleEndOfTopic.sections {
                    let newSection = Section(context: self.context)
                    newSection.sectionId = UUID()
                    newSection.sectionNumber = Int16(section.sectionNumber)
                    newSection.sectionTitle = section.title
                    topic.addToSections(newSection)
                    existingFocusArea.addToSections(newSection)
                    category.addToSections(newSection)
                }
            }
        }
        
        await self.save()
        
    }
    
    //mark topic and section as complete
    func completeTopic(topic: Topic, section: Section? = nil, sequence: Sequence? = nil) async {
        await context.perform {
            if let section = section {
                section.completed = true
            }
            if let sequence = sequence {
                sequence.sequenceStatus = SequenceStatusItem.completed.rawValue
            }
            topic.completed = true
            topic.topicStatus = TopicStatusItem.completed.rawValue
        }
        
        await self.save()
    }
    
    //mark topic as complete using topicId
    func completeTopic2(id: UUID) async {
        
        let request = NSFetchRequest<Topic>(entityName: "Topic")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        await context.perform {
            do {
                let fetchedTopic = try self.context.fetch(request)
                
                if let topic = fetchedTopic.first {
                    topic.completed = true
                    topic.status = TopicStatusItem.completed.rawValue
                }
                
            } catch {
                self.logger.error("Failed to fetch and update topic in CoreData: \(error.localizedDescription)")
            }
            
        }
        
        await self.save()
        
    }
    
}

// MARK: - Questions
extension DataController {

        //save user answer for an question
        //note: questionContent needed when creating new topic, questionId needed when updating topic
        func saveAnswer(questionType: QuestionType, questionContent: String? = nil, questionId: UUID? = nil, userAnswer: Any, customItems: [String]? = nil) async {
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
                    if let answer = userAnswer as? String {
                        question.questionAnswerSingleSelect = answer
                    }
                    
                    if let items = customItems, !items.isEmpty {
                        let arrayString = items.joined(separator: ";")
                        question.singleSelectOptions = arrayString
                        question.editedSingleSelect = true
                        self.logger.log("New single select options: \(arrayString)")
                    }
                    
                case .multiSelect:
                    if let answer = userAnswer as? [String] {
                        let arrayString = answer.joined(separator: ";")
                        question.questionAnswerMultiSelect = arrayString
                    }
                    
                    if let items = customItems, !items.isEmpty {
                        let arrayString = items.joined(separator: ";")
                        question.multiSelectOptions = arrayString
                        question.editedMultiSelect = true
                        self.logger.log("New multi select options: \(arrayString)")
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
        
        //save answer for predefined questions
        func saveAnswerDefaultQuestions(questionType: QuestionType, question: any QuestionProtocol, userAnswer: Any, category: Category? = nil, goal: Goal? = nil, sequence: Sequence? = nil) async {
            await context.perform {
                // create a new question
                let newQuestion = Question(context: self.context)
                newQuestion.questionId = UUID()
                newQuestion.createdAt = getCurrentTimeString()
                newQuestion.questionType = questionType.rawValue
                self.logger.info("Question type being saved: \(newQuestion.questionType) ")
                newQuestion.questionContent = question.content
               
                
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
                
                // add question to category
                if let category = category {
                    category.addToQuestions(newQuestion)
                }
                // add question to goal
                if let goal = goal {
                    newQuestion.goalStarter = true
                    goal.addToQuestions(newQuestion)
                }
                //add question to sequence
                if let sequence = sequence {
                    newQuestion.sequenceRecap = true
                    sequence.addToQuestions(newQuestion)
                }
                        
            }
            
            await self.save()
        }
    
    func deleteSequenceEndQuestions(sequence: Sequence) async {
        let request = NSFetchRequest<Question>(entityName: "Question")
        request.predicate = NSPredicate(format: "sequence == %@ AND sequenceRecap == true", sequence)
        
        await context.perform {
            do {
                let questionsToDelete = try self.context.fetch(request)
                
               
                    for question in questionsToDelete {
                        self.context.delete(question)
                    }
               
            } catch {
                self.logger.error("Failed to fetch or delete questions: \(error.localizedDescription)")
            }
        }
        
        await self.save()
    }
}

extension DataController {
    //MARK: Points
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
                    existingPoints.total = Int64(1)
                } else {
                    let points = Points(context: self.context)
                    points.pointsId = UUID()
                    points.total = Int64(1)
                }
                
            } catch {
                self.logger.error("Error updating points CoreData: \(error)")
            }
        }
        
        await self.save()
        
    }
    
}

// MARK: - Goals and sequences

extension DataController {
    
    //Create a new goal
    func createNewGoal(category: Category?, problemType: String) async -> Goal? {
        
        var newGoal: Goal?
        
        await context.perform {
            
            // Create the new category
            let goal = Goal(context: self.context)
            goal.goalId = UUID()
            goal.goalCreatedAt = getCurrentTimeString()
            goal.goalProblemType = problemType
            goal.goalStatus = GoalStatusItem.active.rawValue
            self.logger.log("Created new goal, type: \(problemType)")
            
            if let category = category {
                self.logger.log("Adding new goal to category: \(category.categoryName)")
                category.addToGoals(goal)
            }
            
            newGoal = goal
        }
        
        await self.save()
        
        return newGoal
    }
    
    // get goals
    func fetchAllGoals() async -> [Goal] {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        var goals: [Goal] = []
        await context.perform {
            
            do {
                goals = try self.context.fetch(request)
            } catch {
                self.logger.log("Error fetching goals: \(error)")
            }
        }
        
        return goals
    }
    
    func changeGoalStatus(goal: Goal, newStatus: GoalStatusItem) async {
        await context.perform {
            
            goal.goalStatus = newStatus.rawValue
            
        }
        await self.save()
        
    }
    
    // delete goals that don't have a plan
    /// happens when user exits early from the new category/topic flow
    func deleteIncompleteGoals() async {
        let request = NSFetchRequest<Goal>(entityName: "Goal")
        
        await context.perform {
            do {
                let goals = try self.context.fetch(request)
                
                // Filter goals with empty goalSequences
                let incompleteGoals = goals.filter { $0.goalSequences.isEmpty }
                
                if incompleteGoals.isEmpty {
                    self.logger.log("No incomplete goals found to delete")
                } else {
                    for goal in incompleteGoals {
                        self.context.delete(goal)
                    }
                    self.logger.log("\(incompleteGoals.count) incomplete goals deleted")
                }
                
            } catch {
                self.logger.error("Failed to fetch or delete incomplete goals: \(error.localizedDescription)")
            }
        }
        
        await self.save()
    }
    
    // save selected plan & create sequence
    func saveSelectedPlan(plan: NewPlan, category: Category, goal: Goal) async {
        await context.perform {
            // build sequence
            let newSequence = Sequence(context: self.context)
            newSequence.sequenceId = UUID()
            newSequence.sequenceCreatedAt = getCurrentTimeString()
            newSequence.sequenceTitle = plan.title
            newSequence.sequenceIntent = plan.intent
            newSequence.sequenceStatus = SequenceStatusItem.active.rawValue
            newSequence.sequenceObjectives = plan.explore.joined(separator: ";")
            
            // create relationships with Category and Goal
            category.addToSequences(newSequence)
            goal.addToSequences(newSequence)
            
            let totalQuests = plan.quests.count
            
            // combine static topics and AI generated ones
            let allTopics: [NewTopic1] = NewTopic1.samples + plan.quests
            
            // save all topics to CoreData
            for newTopic in allTopics {
                self.insertTopic(
                    plan: plan,
                    newTopic: newTopic,
                    sequence: newSequence,
                    category: category,
                    goal: goal,
                    totalQuests: totalQuests
                )
            }
        }
        await save()
    }
    
    private func insertTopic(
            plan: NewPlan,
            newTopic: NewTopic1,
            sequence: Sequence,
            category: Category,
            goal: Goal,
            totalQuests: Int
    ) {
        
        let topic = Topic(context: context)
        topic.topicId = UUID()
        topic.topicCreatedAt = getCurrentTimeString()
        topic.topicTitle = newTopic.title
        topic.topicStatus = TopicStatusItem.locked.rawValue
        //calculate order index based on step type
        if newTopic.questType == QuestTypeItem.retro.rawValue {
            topic.orderIndex = Int16(totalQuests + 1)
        } else {
            topic.orderIndex = Int16(newTopic.questNumber)
        }
        topic.topicEmoji = newTopic.emoji
        topic.topicDefinition = newTopic.objective
        topic.topicQuestType = newTopic.questType
            
            // create relationships
            sequence.addToTopics(topic)
            category.addToTopics(topic)
            goal.addToTopics(topic)
            
            // if this is the “expectations” topic, add its expectations
            if newTopic.questType == QuestTypeItem.expectations.rawValue {
                for item in plan.expectations {
                    let expectation = TopicExpectation(context: context)
                    expectation.expectationId = UUID()
                    expectation.orderIndex = Int16(item.expectationsNumber)
                    expectation.expectationContent = item.content
                    topic.addToExpectations(expectation)
                }
            }
        }
    
    
    

}

// MARK: MISC

extension DataController {
    // MARK: delete all
    func deleteAll() async {
        
        await MainActor.run {
            deletedAllData = false
        }
        
        // 1. First delete categories (which should cascade delete related topics)
        let categoryFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
        let categoryBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: categoryFetchRequest)
        
        // Configure batch to get object IDs for updating the context's state
        categoryBatchDeleteRequest.resultType = .resultTypeObjectIDs
        
        await context.perform {
            do {
                // Execute the category batch delete
                let categoryBatchDelete = try self.context.execute(categoryBatchDeleteRequest) as? NSBatchDeleteResult
                
                // Use the deleted object IDs to update the context's state
                if let deletedCategoryIDs = categoryBatchDelete?.result as? [NSManagedObjectID] {
                    let categoryChanges = [NSDeletedObjectsKey: deletedCategoryIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: categoryChanges, into: [self.context])
                }
                
                // Save context to ensure category deletions are persisted
                try self.context.save()
                
                // 2. Now delete only orphaned topics (those unrelated to any category)
                // Create a fetch request that finds topics not associated with any category
                let topicFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Topic")
                let topicBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: topicFetchRequest)
                topicBatchDeleteRequest.resultType = .resultTypeObjectIDs
                
                // Execute the topic batch delete for orphaned topics
                let topicBatchDelete = try self.context.execute(topicBatchDeleteRequest) as? NSBatchDeleteResult
                
                // Use the deleted object IDs to update the context's state
                if let deletedTopicIDs = topicBatchDelete?.result as? [NSManagedObjectID] {
                    let topicChanges = [NSDeletedObjectsKey: deletedTopicIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: topicChanges, into: [self.context])
                }
                
                // Final save to ensure all changes are persisted
                try self.context.save()
                
                // 3. Delete the user's profile
               let profileFetchRequest = NSFetchRequest<Profile>(entityName: "Profile")
               let profiles = try self.context.fetch(profileFetchRequest)
               
                //delet all found profiles (there should only be one)
               for profile in profiles {
                   self.context.delete(profile)
               }
               
               // Final save to ensure all changes are persisted
               try self.context.save()
            
               self.logger.info("Successfully deleted all categories, orphaned topics, and user profile")
                
            } catch {
                self.logger.error("Error during deletion process: \(error.localizedDescription)")
            }
        }
        
        await MainActor.run {
            deletedAllData = true
        }
    }
}



// MARK: - Current not in use
extension DataController {
    
    // MARK: Categories
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
                    category.categoryEmoji = realm.icon
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
    func createSingleCategory(name: String = "") async -> Category? {
        
        // Find the matching realm data
//        guard let realmData = QuestionCategory.getCategoryData(for: name) else {
//            self.logger.error("No matching realm found for \(name)")
//            return nil
//        }
        // category not in use right now, for now, everything is under category "mix of both"
        let realmData = Realm.realmsData[2]
        
        var newCategory: Category?
        
        await context.perform {
            do {
                // Check if this category already exists
                let request = NSFetchRequest<Category>(entityName: "Category")
                let allCategories = try self.context.fetch(request)
                                
                let matchingCategories = allCategories.filter { category in
                    category.name == realmData.name
                }
                                
                if !matchingCategories.isEmpty {
                    self.logger.info("Category already exists for \(name)")
                    newCategory = matchingCategories.first
                    return
                }
                
                // Create the new category
                let category = Category(context: self.context)
                category.categoryId = UUID()
                category.orderIndex = Int16(allCategories.count)
                category.categoryCreatedAt = getCurrentTimeString()
                category.categoryEmoji = realmData.icon
                category.categoryName = realmData.name
                category.categoryLifeArea = realmData.lifeArea
                
                newCategory = category
                
                try self.context.save()
                
            } catch {
                self.logger.error("Error creating single category: \(error)")
                newCategory = nil
            }
        }
        
        return newCategory
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
                    category.categoryEmoji = realm.icon
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
    
    // MARK: Focus area
    
    func updateFocusAreaStatus(focusArea: FocusArea) async {
        await context.perform {
            //update focus area status to active
            
            self.logger.log("Updating status for focus area: \(focusArea.orderIndex) \(focusArea.focusAreaTitle)")
            
            focusArea.focusAreaStatus = FocusAreaStatusItem.active.rawValue
        }
        
        await self.save()
    
    }
    
    func completeFocusArea(focusArea: FocusArea) async {
        await context.perform {
            focusArea.completedAt = getCurrentTimeString()
            focusArea.focusAreaStatus = FocusAreaStatusItem.completed.rawValue
            
            self.logger.log("Complete focus area: \(focusArea.orderIndex) \(focusArea.focusAreaTitle)")
        }
        
        await self.save()
    }
    
    func completeFocusAreaRecap(focusArea: FocusArea) async {
        await context.perform {
            focusArea.recapComplete = true
            
            self.logger.log("Complete focus area recap: \(focusArea.orderIndex) \(focusArea.focusAreaTitle)")
        }
        
        await self.save()
    }
    
    
    //MARK: Section
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
    
    // MARK: Topic
    
    //create new topic
    func createTopic(suggestion: NewTopicGenerated, topicId: UUID, category: Category) async -> (topicId: UUID?, focusArea: FocusArea?) {
       
        var createdFocusArea: FocusArea? = nil
        
        let request = NSFetchRequest<Topic>(entityName: "Topic")
            request.predicate = NSPredicate(format: "id == %@", topicId as CVarArg)
        
        await context.perform {
            
            do {
                
                let results = try self.context.fetch(request)
                            
                // If no topic found, exit the function
                guard let existingTopic = results.first else {
                    self.logger.log("No topic found with ID: \(topicId)")
                    return
                }
               
                // Update the existing topic with suggestion data
                existingTopic.topicStatus = TopicStatusItem.active.rawValue
                existingTopic.topicCreatedAt = getCurrentTimeString()
               
                let focusAreasTotal = suggestion.focusAreas.count
                existingTopic.focusAreasLimit = Int16(focusAreasTotal)
                
                category.addToTopics(existingTopic)
                
                for newFocusArea in suggestion.focusAreas {
                    let focusArea = FocusArea(context: self.context)
                    focusArea.focusAreaId = UUID()
                    focusArea.focusAreaCreatedAt = getCurrentTimeString()
                    focusArea.orderIndex = Int16(newFocusArea.focusAreaNumber)
                    focusArea.focusAreaTitle = newFocusArea.content
                    focusArea.focusAreaReasoning = newFocusArea.reasoning
                    focusArea.focusAreaEmoji = newFocusArea.emoji
                    
                    existingTopic.addToFocusAreas(focusArea)
                    category.addToFocusAreas(focusArea)
                    
                    if newFocusArea.focusAreaNumber == 1 {
                        createdFocusArea = focusArea
                        focusArea.focusAreaStatus = FocusAreaStatusItem.active.rawValue
                    } else {
                        focusArea.focusAreaStatus = FocusAreaStatusItem.locked.rawValue
                    }
                }
                
                self.addLastFocusArea(topic: existingTopic, category: category, index: focusAreasTotal + 1)
                
                self.newTopic = existingTopic
                self.logger.log("Updated newTopic published variable")
            } catch {
                self.logger.error("Error fetching topic: \(error.localizedDescription)")
            }

        }
        
        await self.save()
        
        return (topicId, createdFocusArea)
    }
    
    private func addLastFocusArea(topic: Topic, category: Category, index: Int) {
        let newFocusArea = FocusArea(context: self.context)
        newFocusArea.focusAreaId = UUID()
        newFocusArea.focusAreaCreatedAt = getCurrentTimeString()
        newFocusArea.focusAreaTitle = EndOfTopic.sampleEndOfTopic.title
        newFocusArea.focusAreaReasoning = EndOfTopic.sampleEndOfTopic.reasoning
        newFocusArea.orderIndex = Int16(index)
        newFocusArea.endOfTopic = true
        topic.addToFocusAreas(newFocusArea)
        category.addToFocusAreas(newFocusArea)
    }
    
    
    // MARK: Other
    
    func saveUserName(name: String) async {
        
        
        await context.perform {
            // First check if a profile already exists
            let request = NSFetchRequest<Profile>(entityName: "Profile")
            
            do {
                let existingProfiles = try self.context.fetch(request)
                
                if let existingProfile = existingProfiles.first {
                    // Update existing profile
                    existingProfile.profileName = name
                } else {
                    // Create new profile if none exists
                    let profile = Profile(context: self.context)
                    profile.profileId = UUID()
                    profile.profileName = name
                }
            } catch {
                print("Error fetching existing profiles: \(error.localizedDescription)")
            }
        }
        
        await self.save()
    }
    
    @MainActor
    func fetchUserProfile() async -> (uuid: UUID?, name: String?) {
        let request = NSFetchRequest<Profile>(entityName: "Profile")
        request.fetchLimit = 1
        
        return await context.perform {
            do {
                let profiles = try self.context.fetch(request)
                if let profile = profiles.first {
                    return (uuid: profile.profileId, name: profile.profileName)
                } else {
                    self.logger.error("No profile found in CoreData")
                    return (uuid: nil, name: nil)
                }
            } catch {
                self.logger.error("Failed to fetch profile from CoreData: \(error)")
                return (uuid: nil, name: nil)
            }
        }
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
