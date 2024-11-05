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
    
    //for creating a brand new topic
    static func gatherContextGeneral(dataController: DataController, loggerCoreData: Logger, topicId: UUID, userInput: [String]? = nil) async -> String? {
        
        var context = "Here is what we know so far about the topic: \n"
        
        guard let topic = await dataController.fetchTopic(id: topicId) else {
               loggerCoreData.error("Failed to fetch topic with ID: \(topicId.uuidString)")
               return nil
        }
        
        context += """
        - topic title: \(topic.title ?? "No title available")\n
        - topic relates to this part of the user's life: \(topic.topicCategory)\n\n
        """
        
        let starterQuestions = topic.topicQuestions.filter { $0.starterQuestion }
        
            
        context += "Here are the questions that the user's response to questions about this topic: \n"
        
        for question in starterQuestions {
           
            context += "Question: \(question.questionContent)\n"
            
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
        
        if let focusArea = userInput {
            context += "The user would like three (no more & no less!) new sections around this: \(focusArea)\n"
        }
        
        //get focus areas
        
        let focusAreas = topic.topicFocusAreas
            .sorted { $0.focusAreaCreatedAt < $1.focusAreaCreatedAt }
        
        for focusArea in focusAreas {
            context += """
            focus area title: \(focusArea.focusAreaTitle)\n
            focus area reasoning: \(focusArea.focusAreaReasoning)\n\n
            """
            
            //get sections that have been completed
            let focusAreaSections = focusArea.focusAreaSections
            
            context += "There are \(focusAreaSections.count) sections in this focus area.\n\n"
            
            if !focusAreaSections.isEmpty {
                
                let completedSections = focusAreaSections
                    .filter { $0.completed == true }
                    .sorted { $0.sectionNumber < $1.sectionNumber }
                
                context += "Here are the sections the user has completed: \n"
                
                for section in completedSections {
                    
                        context += "\n Section number: \(section.sectionNumber).\n Section title: \(section.sectionTitle)\nHere are the questions in this section that the user has already answered:\n"
                        context += getQuestions(section.sectionQuestions)
                }
                
                let incompleteSections = focusAreaSections
                    .filter { $0.completed != true }
                    .sorted { $0.sectionNumber < $1.sectionNumber }
                context += "Here are the sections the user haven't done yet: \n"
                
                for section in incompleteSections {
                
                    context += "\n Section number: \(section.sectionNumber).\nSection title: \(section.sectionTitle)\n The user hasn't answered any questions in this section yet. Here are the questions for this section: \n"
                    context += getQuestions(section.sectionQuestions)
                
                }
                
            }
        }
        
        
        
        return context
    }
    
    //for section recaps
    static func gatherContextUpdateTopic(dataController: DataController, loggerCoreData: Logger, section: Section) async -> String? {
        var context = "The user completed this section: \(section.sectionTitle). Please consider all of the answers from this section to be new information. You should be responding directly to this in your summary and feedback.\n"
        
        // Add answers for questions in the current section
        context += getQuestions(section.sectionQuestions)
        
        // Fetch and add information for the topic, if available
        if let topic = section.topic, let focusArea = section.focusArea {
            context += """
            The user is adding thoughts to this topic:
            - name: \(topic.topicTitle)
            - topic relates to this part of the user's life: \(topic.topicCategory)\n\n
            
            The user is working on a section from this focus area:
            - focus area title: \(focusArea.focusAreaTitle)\n
            - focus area reasoning: \(focusArea.focusAreaReasoning)\n\n
            """
            
            // Add previous sections' answers
            let savedSections = focusArea.focusAreaSections.filter { $0.sectionId != section.sectionId }
            let completedSections = savedSections
                .filter { $0.completed == true }
                .sorted { $0.sectionNumber < $1.sectionNumber }
            
            context += "Here are the sections in this focus area that the user has completed: \n"
            
            for section in completedSections {
                
                context += "\n Section number: \(section.sectionNumber).\n Section title: \(section.sectionTitle)\nHere are the questions in this section that the user has already answered:\n"
                context += getQuestions(section.sectionQuestions)
            }
            
            let incompleteSections = savedSections
                .filter { $0.completed != true }
                .sorted { $0.sectionNumber < $1.sectionNumber }
            
            context += "Here are the sections in this focus area that the user haven't done yet: \n"
            
            for section in incompleteSections {
            
                context += "\n Section number: \(section.sectionNumber).\nSection title: \(section.sectionTitle)\n The user hasn't answered any questions in this section yet. Here are the questions for this section: \n"
                context += getQuestions(section.sectionQuestions)
            
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




