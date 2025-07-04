//
//  TopicProcessor.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 6/5/25.
//

import Foundation
import CoreData
import OSLog

final class TopicProcessor {
    private let context: NSManagedObjectContext
    private let logger = Logger.coreDataEvents

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - process JSON
    // MARK: create topic
    func processNewTopicQuestions(messageText: String, topic: Topic) async throws {
        try await self.context.perform {
            guard let newQuestions = JSONHelper.decode(messageText, as: NewTopicQuestions.self) else {
                self.logger.error("Failed to decode new questions for topic: \(topic.topicTitle)")
                throw ProcessingError.decodingError("New topic questions")
            }

            self.processQuestions(newQuestions.questions, for: topic, in: self.context)
            self.processTopicExpectations(newQuestions.expectations, for: topic, in: self.context)

            try self.context.save()
        }
    }
    
    // MARK: create daily topic
    /// create title, theme, and expectations
    func processNewDailyTopic(messageText: String, existingTopic: TopicDaily? = nil) async throws -> TopicDaily? {
        var newTopic: TopicDaily? = nil
        
        guard let decodedTopic = JSONHelper.decode(messageText, as: NewDailyTopic.self) else {
            self.logger.error("Failed to decode new daily topic")
            throw ProcessingError.decodingError("New daily topic")
        }
        
        try await self.context.perform {
            
            var dailyTopic: TopicDaily
            
            if let savedTopic = existingTopic {
                dailyTopic = savedTopic
            } else {
               dailyTopic = TopicDaily(context: self.context)
                dailyTopic.topicId = UUID()
                dailyTopic.topicCreatedAt = getCurrentTimeString()
            }
            
            dailyTopic.topicStatus = TopicStatusItem.active.rawValue
            dailyTopic.topicEmoji = decodedTopic.emoji
            dailyTopic.topicTitle = decodedTopic.title
            dailyTopic.topicTheme = decodedTopic.theme

            
            self.processTopicExpectations(decodedTopic.expectations, for: dailyTopic, in: self.context)

            try self.context.save()
            
            newTopic = dailyTopic
        }
        
        return newTopic
    }
    
    /// create daily topic questions
    func processNewDailyTopicQuestions(messageText: String, topic: TopicDaily) async throws {
        guard let questions = JSONHelper.decode(messageText, as: NewDailyTopicQuestions.self) else {
            self.logger.error("Failed to decode daily topic questions")
            throw ProcessingError.decodingError("Daily topic questions")
        }
        
        try await self.context.perform {
            self.processQuestions(questions.questions, for: topic, in: self.context)
            
            // Add scripted daily topic questions
            self.processQuestions(NewQuestion.questionsDailyTopic, for: topic, in: self.context, reflectQuestion: true, questionsCount: questions.questions.count)
            
            try self.context.save()
        }
    }

    private func processQuestions(_ newQuestions: [NewQuestion], for topic: TopicRepresentable, in context: NSManagedObjectContext, reflectQuestion: Bool = false, questionsCount: Int = 0) {
        for newQuestion in newQuestions {
            let question = Question(context: context)
            question.questionId = UUID()
            question.questionContent = newQuestion.content
            question.questionNumber = reflectQuestion ? Int16(questionsCount + newQuestion.questionNumber + 1) : Int16(newQuestion.questionNumber)
            question.questionType = newQuestion.questionType.rawValue
            question.reflectQuestion = reflectQuestion && (newQuestion.id < 2 || newQuestion.id == 4)
            question.goalStarter = reflectQuestion && newQuestion.id > 1 && newQuestion.id < 4
            
            switch newQuestion.questionType {
            case .singleSelect:
                question.questionSingleSelectOptions = newQuestion.options.map { $0.text }.joined(separator: ";")
            case .multiSelect:
                question.questionMultiSelectOptions = newQuestion.options.map { $0.text }.joined(separator: ";")

            default:
                break
            }

            topic.addToQuestions(question)
        }
    }

    private func processTopicExpectations(_ expectations: [NewExpectation], for topic: TopicRepresentable, in context: NSManagedObjectContext) {
        for item in expectations {
            let expectation = TopicExpectation(context: context)
            expectation.expectationId = UUID()
            expectation.orderIndex = Int16(item.expectationsNumber)
            expectation.expectationContent = item.content
            topic.addToExpectations(expectation)
        }
    }
    
    // MARK: topic type "break"
    func processTopicBreak(messageText: String, topic: Topic) async throws {
        let arguments = messageText
        
        // Decode the arguments to get the new section data
        guard let newBreak = JSONHelper.decode(arguments, as: NewTopicBreak.self) else {
            self.logger.error("Couldn't decode arguments for topic break.")
            throw ProcessingError.decodingError("topic break")
        }

        try await self.context.perform {
            
           for card in newBreak.cards {
               let topicBreak = TopicBreak(context: self.context)
               topicBreak.breakId = UUID()
               topicBreak.breakContent = card.cardContent
               topicBreak.orderIndex = Int16(card.cardNumber)
               topic.addToBreaks(topicBreak)
               
           }
            // Save to coredata
           try self.context.save()
            
        }
    }
    
    // MARK: topic summary & reflection
    func processTopicOverview(messageText: String, topic: TopicRepresentable) async throws {
        let arguments = messageText
        
        // Decode the arguments to get the new section data
        guard let newRecap = JSONHelper.decode(arguments, as: NewTopicRecap.self) else {
            self.logger.error("Couldn't decode arguments for topic review.")
            throw ProcessingError.decodingError("topic review")
        }

        try await self.context.perform {

            let review = TopicReview(context: self.context)
            review.reviewId = UUID()
            review.reviewCreatedAt = getCurrentTimeString()
            review.reviewSummary = newRecap.summary
            review.overviewGenerated = true
            topic.assignReview(review)
           
            for item in newRecap.feedback {
               let feedback = TopicFeedback(context: self.context)
               feedback.feedbackId = UUID()
               feedback.orderIndex = Int16(item.feedbackNumber)
               feedback.feedbackContent = item.content
               
               topic.addToFeedback(feedback)
            }
            
            if let areas = newRecap.areas {
                let questions = topic.topicQuestions
                // find the question that asks user which topic they want to dive into next
                let question = questions.filter { $0.questionContent ==  NewQuestion.questionsDailyTopic[2].content }.first
                
                if let question = question {
                    var questionOptions = areas
                    questionOptions.append(CustomOptionType.other.rawValue)
                    question.questionMultiSelectOptions = questionOptions.joined(separator: ";")
                }
            }

            // Save to coredata
            try self.context.save()
            
        }
    }
    
}

// MARK: - Save to CoreData
extension TopicProcessor {
    
    //save user answer for an question
    //note: questionContent needed when creating new topic, questionId needed when updating topic
    func saveAnswer(questionType: QuestionType, topic: TopicRepresentable?, questionContent: String? = nil, questionId: UUID? = nil, userAnswer: Any, customItems: [String]? = nil) async throws {
        try await context.perform {
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
                if let topic = topic {
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
            
            // Mark the question as completed if it's not already and there's an answer from the user
            if !question.completed && !(String(describing: userAnswer).isEmpty) {
                question.completed = true
            }
            
            // Save to coredata
            try self.context.save()
        }
    
    }
    
    // create topic for next day
    func createDailyTopic(topicDate: String = "") async throws -> TopicDaily? {
        var newTopic: TopicDaily? = nil
        
        try await self.context.perform {
            let dailyTopic = TopicDaily(context: self.context)
            dailyTopic.topicId = UUID()
         
            // 1) Formatter must match your getCurrentTimeString()/getNextDayString()
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
           formatter.timeZone = TimeZone(secondsFromGMT: 0)

           // 2) If caller passes an empty string, default to now in UTC
           let utcDateString = topicDate.isEmpty
            ? getCurrentTimeString()
               : topicDate
           dailyTopic.topicCreatedAt = utcDateString

           // 3) Parse it back into a Date (fallback to now if it fails)
           let createdAtDate = formatter.date(from: utcDateString) ?? Date()

           // 4) Decide status based on local “is today?”
           let calendar = Calendar.current
           let status: TopicStatusItem = calendar.isDateInToday(createdAtDate)
               ? .active
               : .locked

           dailyTopic.topicStatus = status.rawValue
            
            
            try self.context.save()
            
            newTopic = dailyTopic
        }
        
        return newTopic
    }
    
    //mark topic and section as complete
    func completeTopic(topic: TopicRepresentable, section: Section? = nil, sequence: Sequence? = nil) async throws {
       try await context.perform {
            if let section = section {
                section.completed = true
            }
            if let sequence = sequence {
                sequence.sequenceStatus = SequenceStatusItem.completed.rawValue
            }
          
            topic.topicStatus = TopicStatusItem.completed.rawValue
            
            // Save to coredata
            try self.context.save()
        }
    }
    
    // mark topics as missed
    func changeTopicsStatus(topics: [TopicRepresentable], newStatus: TopicStatusItem) async throws {
       try await context.perform {
           for topic in topics {
               topic.topicStatus = newStatus.rawValue
           }
           
           if FeatureFlags.isStaging {
               self.logger.log("\(topics.count) topics' status updated to \(newStatus.rawValue)")
           }
           
            // Save to coredata
            try self.context.save()
        }
    }
    
    // delete topic
    func deleteTopic(_ topic: TopicRepresentable) async throws {
        try await context.perform {
            self.context.delete(topic as! NSManagedObject)
            
            try self.context.save()
        }
    }
    
    // delete goals that don't have a plan
    func deleteIncompleteGoals(_ incompleteGoals: [Goal]) async throws {
        try await context.perform {
            for goal in incompleteGoals {
                self.context.delete(goal)
            }
            self.logger.log("\(incompleteGoals.count) incomplete goals deleted")
            
            
            // Save to coredata
            try self.context.save()
        }
        
    }
    
}

// MARK: - new topic for a plan (sequence)
struct NewTopicQuestions: Codable, Hashable {
    let questions: [NewQuestion]
    let expectations: [NewExpectation]
}

//question belongs to a section
struct NewQuestion: Codable, Hashable, QuestionProtocol {
    var id: Int { questionNumber } // Computed property using questionNumber as id
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

// MARK: - daily topic
struct NewDailyTopic: Codable, Hashable {
    let theme: String
    let title: String
    let emoji: String
    let expectations: [NewExpectation]
}

struct NewDailyTopicQuestions: Codable, Hashable {
    let questions: [NewQuestion]
}

// MARK: - topic break
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

// MARK: - topic recap
struct NewTopicRecap: Codable, Hashable {
    let summary: String
    let feedback: [NewFeedback]
    let areas: [String]?
}

struct NewFeedback: Codable, Hashable {
    let feedbackNumber: Int
    let content: String

    enum CodingKeys: String, CodingKey {
        case feedbackNumber = "feedback_number"
        case content
    }
}

