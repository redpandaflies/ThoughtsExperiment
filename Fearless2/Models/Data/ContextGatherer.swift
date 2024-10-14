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
    static func gatherContext(dataController: DataController, loggerCoreData: Logger, topicId: UUID) async -> String? {
        
        var context = "Here is more context on the topic: \n"
        
       
            let fetchedTopic = await dataController.fetchTopic(id: topicId)
            
            if let topic = fetchedTopic {
                context += "The user is adding thoughts to this topic:\n"
                context += "- name: \(topic.topicTitle)\n"
                context += "- existing summary: \(topic.topicSummary)\n"
                context += "- latest feedback/reaction: \(topic.topicFeedback)"
            }
            
       
        return context
    }
}



struct ContextGathererNewTopic {
    static func gatherContext(dataController: DataController, loggerCoreData: Logger, topicId: UUID) async -> String? {
        
        var context = "Here is what we know so far about the new topic: \n"
        
       
        let fetchedTopic = await dataController.fetchTopic(id: topicId)
        if let topic = fetchedTopic {
            context += "User's description of the topic: \(topic.topicUserDescription)\n"
        }
        

        if let topicQuestions = fetchedTopic?.topicQuestions {
            
            context += "Here are the questions that the user was asked and the user's responses: \n"
            
            for question in topicQuestions {
               
                context += "Question: \(question.questionContent) \n"
                
                if question.questionType == "scale" {
                    context += "Answer: on a scale of 0 to 10, this is a \(question.answerScale)\n"
                } else {
                    context += "Answer: \(question.questionAnswerOpen)\n"
                }
            }
        }
            
       
        return context
    }
}
