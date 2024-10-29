//
//  ContextGatherer.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//

import Foundation
import OSLog

@MainActor
struct ContextGatherer {
    
    static func gatherContextNewTopic(dataController: DataController, loggerCoreData: Logger, topicId: UUID) async -> String? {
        
        var context = "Here is what we know so far about the new topic: \n"
        
       
        let fetchedTopic = await dataController.fetchTopic(id: topicId)
//        if let topic = fetchedTopic {
//            context += "User's description of the topic: \(topic.topicUserDescription)\n"
//        }
        

        if let topicQuestions = fetchedTopic?.topicQuestions {
            
            context += "Here are the questions that the user was asked and the user's responses: \n"
            
            for question in topicQuestions {
               
                context += "Question: \(question.questionContent) \n"
                
                if let questionType = QuestionType(rawValue: question.questionType) {
                    switch questionType {
                    case .scale:
                        context += "Answer: on a scale of 0 to 10, this is a \(question.answerScale)\n"
                    case .multiSelect:
                        context += "Answer: \(question.questionAnswerMultiSelect)\n"
                    case .open:
                        context += "Answer: \(question.questionAnswerOpen)\n"
                    }
                } else {
                    context += "Answer not found for this question\n"
                }
            }
        }
        
        return context
    }
    

    static func gatherContextUpdateTopic(dataController: DataController, loggerCoreData: Logger, section: Section) async -> String? {
        var context = "The user completed this section: \(section.sectionTitle). Please consider all of the answers from this section to be new information. You should be responding directly to this in your summary and feedback.\n"
        
        // Add answers for questions in the current section
        context += getQuestions(section.sectionQuestions)
        
        // Fetch and add information for the topic, if available
        if let topic = section.topic {
            context += """
            The user is adding thoughts to this topic:
            - name: \(topic.topicTitle)
            - topic relates to this part of the user's life: \(topic.topicCategory)
            """
            
            // Add previous sections' answers
            let savedSections = topic.topicSections.filter { $0.sectionId != section.sectionId }
            for section in savedSections {
                if section.completed {
                    context += "\nSection title: \(section.sectionTitle)\nHere are the questions in this section that the user has already answered:\n"
                    context += getQuestions(section.sectionQuestions)
                } else {
                    context += "\nSection title: \(section.sectionTitle)\n The user hasn't answered any questions in this section yet. Here are the questions for this section: \n"
                    context += getQuestions(section.sectionQuestions)
                }
            }
        }

        return context
    }

    // Helper function to format questions and answers
    private static func getQuestions(_ questions: [Question]) -> String {
        var result = ""
        for question in questions {
            result += "- question: \(question.questionContent)\n"
            if question.completed {
                if let questionType = QuestionType(rawValue: question.questionType) {
                    switch questionType {
                    case .scale:
                        result += "Answer: on a scale of 0 to 10, this is a \(question.answerScale)\n"
                    case .multiSelect:
                        result += "Answer: \(question.questionAnswerMultiSelect)\n"
                    case .open:
                        result += "Answer: \(question.questionAnswerOpen)\n"
                    }
                } else {
                    result += "Answer not found for this question\n"
                }
            }
        }
        return result
    }
}




