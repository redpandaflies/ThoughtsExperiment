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
    
    static func gatherContextGeneral(dataController: DataController, loggerCoreData: Logger, topicId: UUID, transcript: String? = nil, userInput: [String]? = nil, focusArea: FocusArea? = nil) async -> String? {
        
        var context = "Here is what we know so far about the topic: \n"
        
        guard let topic = await dataController.fetchTopic(id: topicId) else {
               loggerCoreData.error("Failed to fetch topic with ID: \(topicId.uuidString)")
               return nil
        }
        
        context += """
        - topic title: \(topic.title ?? "No title available")\n
        - topic relates to this part of the user's life: \(topic.topicCategory)\n\n
        """
        
        //questions users answered when creating topic
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
        
        if let newFocusArea = focusArea {
            context += "The user would like three (no more & no less!) new sections around this: \(newFocusArea.focusAreaTitle). The reasoning for it is: \(newFocusArea.focusAreaReasoning)\n"
        }
        
        if let currentTranscript = transcript {
            context += "This is the transcript for the new entry. Please use this when creating the new entry title, summary, insights, and feedback:\n\(currentTranscript)\n"
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
        
        //get entries
        let entries = topic.topicEntries
        
        if !entries.isEmpty {

            for entry in entries {
                context += """
                    \n title: \(entry.entryTitle)
                    summary: \(entry.entrySummary)\n
                    Here are the entry insights: \n
                """

                for insight in entry.entryInsights {
                    context += """
                        insight: \(insight.insightContent) \n
                    """
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
    
    //for focus area summary
    static func gatherContextFocusArea(dataController: DataController, loggerCoreData: Logger, focusArea: FocusArea) async -> String? {
        var context = "The user is wrapping up this focus area: \(focusArea.focusAreaTitle). Your summary, feedback, and insights should be created based on the user's answers for the sections below.\n"
        
        // Fetch and add information for the topic, if available
        if let topic = focusArea.topic {
            context += """
            The user is adding thoughts to this topic:
            - name: \(topic.topicTitle)
            - topic relates to this part of the user's life: \(topic.topicCategory)\n\n
            
            The user is working on a section from this focus area:
            - focus area title: \(focusArea.focusAreaTitle)\n
            - focus area reasoning: \(focusArea.focusAreaReasoning)\n\n
            """
            
            // Add previous sections' answers
            let savedSections = focusArea.focusAreaSections
            
            context += "Here are the sections in this focus area. Assume that questions without answers are the ones that the user purposefully skipped: \n"
            
            for section in savedSections {
                
                context += "\n Section number: \(section.sectionNumber).\n Section title: \(section.sectionTitle)\nHere are the questions in this section that the user has already answered:\n"
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




