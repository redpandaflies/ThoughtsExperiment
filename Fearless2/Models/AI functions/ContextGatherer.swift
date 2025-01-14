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
    
    static func gatherContextGeneral(dataController: DataController, loggerCoreData: Logger, selectedAssistant: AssistantItem? = nil, topicId: UUID, transcript: String? = nil, userInput: [String]? = nil, focusArea: FocusArea? = nil) async -> String? {
        
        guard let assistant = selectedAssistant else {
            loggerCoreData.error("No assistant selected")
            return nil
        }
        
        var context = ""
        
       switch assistant {
           
         case .focusArea:
            context += "The user would like new sections for this focus area: \(focusArea?.focusAreaTitle ?? ""). The focus area is related to the topic below.\n\n"
       case .focusAreaSummary:
            context += "The user is wrapping up this focus area: \(focusArea?.focusAreaTitle ?? ""). The focus area is related to the topic below.\n\n"
           default:
               break
        }
        
        
        //topic info
       context += "Here is what we know so far about the topic: \n"
        
        guard let topic = await dataController.fetchTopic(id: topicId) else {
               loggerCoreData.error("Failed to fetch topic with ID: \(topicId.uuidString)")
               return nil
        }

        
        context += """
        - topic title: \(topic.topicTitle)\n\n
        """
        
        //get user's response to "What would resolve this topic?"
        let resolveQuestion = topic.topicQuestions.filter { $0.content == QuestionsNewTopic.questions[1].content }
        
            
        context += "This is what the user believes will resolve the topic: \(String(describing: resolveQuestion.first?.questionAnswerOpen))\n\n"
        
//        if let currentTranscript = transcript {
//            context += "This is the transcript for the new entry. Please use this when creating the new entry title, summary, insights, and feedback:\n\(currentTranscript)\n"
//        }
        
        //get focus areas for topic
        let focusAreas = topic.topicFocusAreas
            .sorted { $0.focusAreaCreatedAt < $1.focusAreaCreatedAt }
        
        var totalFocusAreas: Int {
            switch assistant {
                case .focusArea:
                 return focusAreas.count - 1 //less 1 because focus area has already been created in CoreData, but it has no sections
                default:
                 return focusAreas.count
            }
            
        }
        
        context += "The level of this topic is \(totalFocusAreas).\n\n"
        
        if totalFocusAreas > 0 {
            context += "Here are all the paths for this topic: \n\n"

            for focusArea in focusAreas {
                context += """
                focus area title: \(focusArea.focusAreaTitle)
                focus area reasoning: \(focusArea.focusAreaReasoning)\n\n
                """

            }
        }
        
        //send section of last completed, should be the same as the focus area for recap
        var lastFocusArea: FocusArea?
        

        switch assistant {
            case .focusArea, .focusAreaSuggestions:
            lastFocusArea = focusAreas.last(where: { $0.completed })
            case .focusAreaSummary:
            lastFocusArea = focusAreas.last
            default:
                break
        }
        
        
        if let currentFocusArea = lastFocusArea {
            let focusAreaSections = currentFocusArea.focusAreaSections.sorted { $0.sectionNumber < $1.sectionNumber }
            
            switch assistant {
                
                case .focusAreaSummary:
                    context += "These are the sections of the focus area the user just completed. The recap should be focused on the info in these sections"
                    
                case .focusArea, .focusAreaSuggestions:
                    context += "The latest completed focus area is: \(currentFocusArea.focusAreaTitle). There are \(focusAreaSections.count) sections in this focus area. \n\n"
                
                default:
                    break
            }
            
            if !focusAreaSections.isEmpty {
                
                context += "For each section, there are a series of questions. If there is no answer for a question, assume the user deliberately skipped it."
                
                for section in focusAreaSections {
                    
                    context += "\n\nSection number: \(section.sectionNumber).\n Section title: \(section.sectionTitle)\nHere are the questions in this section and the user's answers. :\n"
                    context += getQuestions(section.sectionQuestions)
                }
                
            }
        }
        
        let topicInsights = topic.topicInsights.filter {
            $0.markedSaved
        }
        
        if !topicInsights.isEmpty {
            context += "\n\nHere are the insights the user saved for this topic. Saved insights are ideas/key points that the user especially cared about.\n"
            
            for insight in topicInsights {
                context += "\(insight.insightContent)\n"
            }
        }
        
        return context
    }
    
    //for create new topic
    static func gatherContextNewTopic(dataController: DataController, loggerCoreData: Logger, topicId: UUID) async -> String? {
        
        guard let topic = await dataController.fetchTopic(id: topicId) else {
               loggerCoreData.error("Failed to fetch topic with ID: \(topicId.uuidString)")
               return nil
        }
        
        //questions users answered when creating topic
        let starterQuestions = topic.topicQuestions.filter { $0.starterQuestion }
        
            
        var context = "The user wants to create a new topic. Here are the user's responses to questions about it: \n"
        
        for question in starterQuestions {
           
            context += "Question: \(question.questionContent)\n"
            
            if let questionType = QuestionType(rawValue: question.questionType) {
                switch questionType {
                case .singleSelect:
                    context += "Answer: \(question.questionAnswerSingleSelect)\n"
                case .multiSelect:
                    context += "Answer: \(question.questionAnswerMultiSelect)\n"
                case .open:
                    context += "Answer: \(question.questionAnswerOpen)\n"
                }
            } else {
                context += "Answer not found for this question\n"
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
                    case .singleSelect:
                        result += "Answer: on a scale of 0 to 10, this is a \(question.questionAnswerSingleSelect)\n"
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

    //for understand
    static func gatherContextUnderstand(dataController: DataController, loggerCoreData: Logger, question: String) async -> String? {
        var context = "The user would like to know this about themselves: \(question)\n Please provide an answer based on the context provided below about the user.\n\n"
        
        //get all active topics
       let topics = await dataController.fetchAllTopics()
        
        if !topics.isEmpty {
            
            for topic in topics {
                context += """
                - topic title: \(topic.title ?? "No title available")\n
                - topic relates to this part of the user's life: \(topic.topicCategory)\n\n
                """
                
                //all saved insights
                context += "Here are the user's saved insights for this topic: \n"
                let topicInsights = topic.topicInsights.filter { $0.markedSaved == true }
                for insight in topicInsights {
                    context += "-\(insight.insightContent)"
                }
                
                //all completed section summaries
                context += "\n\nHere are the summaries and insights from the sections that have been completed. A section is a series of questions the user answers about the topic.\n\n"
                let sections = topic.topicSections.filter { $0.completed == true }
                for section in sections {
                    if let summary = section.summary {
                        context += """
                            section title: \(section.sectionTitle)\n
                            section summary: \(summary.summarySummary)\n
                        """
                        context += "here are the section insights: \n"
                        for insight in summary.summaryInsights {
                            context += "-\(insight.insightContent)\n"
                        }
                    }
                }
                
                //all entry summaries
                context += "\n\nHere are the summaries every entry related to this topic.\n\n"
                for entry in topic.topicEntries {
                    context += """
                        \(entry.entryTitle)\n
                        \(entry.entrySummary)\n\n
                    """
                }
            }//topic
            
            
        }

        return context
    }
    
}




