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
        
        guard let topic = await dataController.fetchTopic(id: topicId) else {
               loggerCoreData.error("Failed to fetch topic with ID: \(topicId.uuidString)")
               return nil
        }
        
        guard let category = topic.category else {
            loggerCoreData.error("Failed to get related cateogry")
            return nil
        }
        
        var context = "Life area: \(category.categoryLifeArea)\n\n"
        
        switch assistant {
           
           case .focusArea:
                context += "Current path (focus area): \(focusArea?.focusAreaTitle ?? "").\n\n"

           default:
                break
        }
        
        
        //topic info
        context += "Here is what we know so far about the quest this belongs to: \n\n"

        context += """
        a) quest title and reasoning: \(topic.topicTitle) – \(topic.topicDefinition)\n\n
        """

        //get focus areas for topic
        let focusAreas = topic.topicFocusAreas
            .sorted { $0.focusAreaCreatedAt < $1.focusAreaCreatedAt }
        
        let completedFocusAreas = focusAreas
            .filter { $0.focusAreaStatus == FocusAreaStatusItem.completed.rawValue }
    
        if selectedAssistant == .focusArea || selectedAssistant == .focusAreaSuggestions || selectedAssistant == .topicOverview {
            
            var totalFocusAreas: Int {
                switch selectedAssistant {
               
                case .focusAreaSuggestions:
                    return focusAreas.count
                case .focusArea, .topicOverview:
                    return completedFocusAreas.count
                default:
                    return 0
                }
            }
            
            var focusAreasList: [FocusArea] {
                switch selectedAssistant {
               
                case .focusAreaSuggestions:
                    return focusAreas
                case .focusArea, .topicOverview:
                    return completedFocusAreas //new focus area will have been created in CoreData, but there will be no content for it yet or it's the quest complete focus area which we don't need to send
                default:
                    return focusAreas
                }
            }
            
            if totalFocusAreas > 0 {
                context += "b) completed paths, their reasoning, and their summary within this quest: \n\n"

                for focusArea in focusAreasList {
                    context += """
                    - Path title: \(focusArea.focusAreaTitle)
                    - Path reasoning: \(focusArea.focusAreaReasoning)\n
                    """
                
                    if let summary = focusArea.summary?.summarySummary {
                        context += "- Path summary: \(summary)\n\n"
                    }
                    
                }
            }
        }
        
        
        //send sections for focus area recap
        if selectedAssistant == .focusAreaSummary {
            let lastFocusArea = focusAreas.last
            
            if let currentFocusArea = lastFocusArea {
                let focusAreaSections = currentFocusArea.focusAreaSections.sorted { $0.sectionNumber < $1.sectionNumber }
        
                context += """
                Current path (focus area):
                - Path title: \(currentFocusArea.focusAreaTitle)
                - Path reasoning: \(currentFocusArea.focusAreaReasoning)\n
                """
                        

                if !focusAreaSections.isEmpty {
                    
                    context += "- Questions answered by the user:\n"
                    
                    for section in focusAreaSections {
                        context += getQuestions(section.sectionQuestions)
                    }
                    
                    context += "\n"
                }
            }
            
        }

        //get questions answered when creating category
        context += getOnboardingContext(from: category)
        
        //topic focus area limit
        context += "\nThis quest will have exactly \(topic.focusAreasLimit) paths (focus areas)."
        
        return context
       
    }
    
    //for topic suggestions
    static func gatherContextTopicSuggestions(dataController: DataController, loggerCoreData: Logger, category: Category) async -> String? {
        var context = "Current life area: \(category.categoryLifeArea).\n\n"
        
        // Get focus areas limit
        let highestFocusAreaTopic = category.categoryTopics.max(by: { $0.focusAreasLimit < $1.focusAreasLimit })
        let highestFocusAreasLimit = highestFocusAreaTopic?.focusAreasLimit ?? 0
        let focusAreasLimit = min(max(highestFocusAreasLimit + 1, 2), 5)
        context += "Please generate exactly \(focusAreasLimit) focus areas for each quest.\n\n"
        
        //get questions answered when creating category
        context += getOnboardingContext(from: category)
        
        // Get all topics
        let topics = category.categoryTopics
        
        if !topics.isEmpty {
            // Sort topics by creation date string, earliest first
            let sortedTopics = topics.sorted { $0.topicCreatedAt < $1.topicCreatedAt }
            context += "List of quests the user already started and completed, ordered from earliest to latest:\n"
            
            for topic in sortedTopics {
                context += """
                a) quest title and reasoning: \(topic.topicTitle) – \(topic.topicDefinition)
                b) paths, their reasoning, and their summary within this quest: \n\n
                """
                
                let focusAreas = topic.topicFocusAreas
                
                for focusArea in focusAreas {
                    context += """
                    - Path title: \(focusArea.focusAreaTitle)
                    - Path reasoning: \(focusArea.focusAreaReasoning)\n
                    """
                    if let summary = focusArea.summary?.summarySummary {
                        context += "- Path summary: \(summary)\n\n"
                    }
                }
            }
        }

        return context
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
                - topic relates to this part of the user's life: \(topic.category?.categoryLifeArea ?? "none, no category found")\n\n
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


// MARK: reusable code
extension ContextGatherer {
    // Helper function to format questions and answers
    private static func getQuestions(_ questions: [Question]) -> String {
        var result = ""
        for question in questions {
            result += "Q: \(question.questionContent)\n"
            if question.completed {
                if let questionType = QuestionType(rawValue: question.questionType) {
                    switch questionType {
                    case .singleSelect:
                        result += "A: \(question.questionAnswerSingleSelect)\n"
                    case .multiSelect:
                        result += "A: \(question.questionAnswerMultiSelect)\n"
                    case .open:
                        result += "A: \(question.questionAnswerOpen)\n"
                    }
                } else {
                    result += "Answer not found for this question\n"
                }
            }
        }
        return result
    }
    
    private static func getOnboardingContext(from category: Category) -> String {
        var context = "User's answers to onboarding questions for this life area:\n"
        
        let categoryQuestions = category.categoryQuestions
            .filter { $0.categoryStarter == true }
            .sorted { $0.questionCreatedAt < $1.questionCreatedAt }
        
        context += getQuestions(categoryQuestions)
        
        return context
    }
}

