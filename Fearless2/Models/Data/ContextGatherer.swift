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
        if let topic = fetchedTopic {
            context += "User's description of the topic: \(topic.topicUserDescription)\n"
        }
        

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
    

    static func gatherContextUpdateTopic(dataController: DataController, loggerCoreData: Logger, topicId: UUID, sectionId: UUID? = nil) async -> String? {

        var context = ""
        
        let fetchedTopic = await dataController.fetchTopic(id: topicId)

        if let topic = fetchedTopic {
            context += "The user is adding thoughts to this topic:\n"
            context += "- name: \(topic.topicTitle)\n"
            context += "- existing summary: \(topic.topicSummary)\n"
            context += "- latest feedback/reaction: \(topic.topicFeedback)\n\n"
            
            for section in topic.topicSections {
                context += "Section title: \(section.sectionTitle)\n"
                context += "Section category: \(section.sectionCategory)\n"
                context += "Here are the questions in this section that the user has already answered:\n"
                
            }
            
            for question in topic.topicQuestions {
                if question.completed {
                    context += "- question: \(question.questionContent)\n"
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
            
        }

        if let sectionId = sectionId {
            let fetchedSection = await dataController.fetchSection(id: sectionId)
            
            if let section = fetchedSection {
                context += "The user completed this section: \(section.sectionTitle). Please consider all of the answers from this section to be new information. You should be responding directly to this in your feedback.\n"
            }
        }
            


        return context
    }
}




