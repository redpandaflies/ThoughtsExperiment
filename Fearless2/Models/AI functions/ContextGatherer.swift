//
//  ContextGatherer.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/3/24.
//

import Foundation
import OSLog

/// use """ so that the text shows up as markdown in the openAI assistant dashboard

@MainActor
struct ContextGatherer {
    
    // for creating new goal, plan suggestions, plan summary
    static func gatherContext(dataController: DataController, loggerCoreData: Logger, selectedAssistant: AssistantItem, category: Category, goal: Goal, sequence: Sequence? = nil) async -> String? {
        
        var context = ""
    
        // current goal info, with problem statement from new goal flow
        if !goal.goalTitle.isEmpty {
            context += """
                Current topic:\n
            """
            context += addGoalInfo(goal: goal)
        }

        //get questions answered when creating goal
        context += getNewGoalContext(goal: goal, category: category)
        
      
        if selectedAssistant == .planSuggestion || selectedAssistant == .sequenceSummary {
            // get plans and steps for the goal
            /// get plan summaries
            let sequences = goal.goalSequences
            
            if !sequences.isEmpty {
                let planSummaries = goal.goalSequenceSummaries
                
                context += getSequenceSummaries(summaries: planSummaries)
            }
            
            /// current plan (for plan recap only)
            if let sequence = sequence {
                
                context += """
                    The user needs the retrospective for this plan: \(sequence.sequenceTitle).
                    a) description: \(sequence.sequenceIntent)
                    b) objectives: \(sequence.sequenceObjectives)\n\n
                """
            
                // get answers from plan recap flow
                context +=  getSequenceRecapAnswers(sequence: sequence)
                
                // get steps
                context += getTopicsList(topics: sequence.sequenceTopics)
                
                // other plans for the current goal
                context += getOtherSequences(currentSequence: sequence, goalSequences: goal.goalSequences)
                
            }
            
            // Other completed and ongoing goals
            let fetchedGoals = await dataController.fetchAllGoals()
            //filter out current goal
            let remainingGoals = fetchedGoals.filter { $0.goalId != goal.goalId }
            
            if remainingGoals.isEmpty {
                context += """
                    Here are the user's other completed and ongoing goals:\n
                """
                
                for goal in remainingGoals {
                    context += """
                        a) goal: \(goal.goalTitle)
                        b) type: \(goal.goalProblemType)
                        c) problem: \(goal.goalProblem)
                        d) resolution: \(goal.goalResolution)\n 
                    """
                    
                    let planSummaries = goal.goalSequenceSummaries
                    
                    context += getSequenceSummaries(summaries: planSummaries)
                    
                }
            }
        }

        return context
    }
    
    //for new topic
    static func gatherContextTopic(dataController: DataController, loggerCoreData: Logger, topic: Topic) async -> String? {
        guard let topic = await dataController.fetchTopic(id: topic.topicId) else {
            loggerCoreData.error("Failed to fetch topic with ID: \(topic.topicId.uuidString)")
               return nil
        }
        
        guard let category = topic.category else {
            loggerCoreData.error("Failed to get related cateogry")
            return nil
        }
        guard let goal = category.categoryGoals.first else {
            loggerCoreData.error("Failed to get related goal")
            return nil
        }
        
        let sequence = topic.sequence
        
        // Step the user is requesting questions for
        var context = """
            Current step: \(topic.topicTitle).
            a) objective: \(topic.topicDefinition)
            b) type: \(topic.topicQuestType). \n\n
        """
        
        // step questions for topic/step summary
        let questions = topic.topicQuestions
        if !questions.isEmpty {
            context += """
                Answers for questions in this step:\n
            """
            context += getQuestions(questions)
        }

        //goal info
        context += """
            This step is related to this topic: \n
        """
        context += addGoalInfo(goal: goal)
        
        //sequence info
        if let sequence = sequence {
            
            //plan details
            context += """
                This step belongs to this plan: \n
            """
            context += getSequenceDetails(sequence: sequence)
            
            // other plan topics
            let sequenceTopics = sequence.sequenceTopics.filter { $0.topicId != topic.topicId}
            context += """
                Completed and locked steps in this plan are:\n
            """
            context += getTopicsList(topics: sequenceTopics)
            
            // other plans for the current goal
            context += getOtherSequences(currentSequence: sequence, goalSequences: goal.goalSequences)
        }

        return context
    }
    
    //for understand
//    static func gatherContextUnderstand(dataController: DataController, loggerCoreData: Logger, question: String) async -> String? {
//        var context = "The user would like to know this about themselves: \(question)\n Please provide an answer based on the context provided below about the user.\n\n"
//        
//        //get all active topics
//       let topics = await dataController.fetchAllTopics()
//        
//        if !topics.isEmpty {
//            
//            for topic in topics {
//                context += """
//                - topic title: \(topic.title ?? "No title available")\n
//                - topic relates to this part of the user's life: \(topic.category?.categoryLifeArea ?? "none, no category found")\n\n
//                """
//                
//                //all saved insights
//                context += "Here are the user's saved insights for this topic: \n"
//                let topicInsights = topic.topicInsights.filter { $0.markedSaved == true }
//                for insight in topicInsights {
//                    context += "-\(insight.insightContent)"
//                }
//                
//                //all completed section summaries
//                context += "\n\nHere are the summaries and insights from the sections that have been completed. A section is a series of questions the user answers about the topic.\n\n"
//                let sections = topic.topicSections.filter { $0.completed == true }
//                for section in sections {
//                    if let summary = section.summary {
//                        context += """
//                            section title: \(section.sectionTitle)\n
//                            section summary: \(summary.summarySummary)\n
//                        """
//                        context += "here are the section insights: \n"
//                        for insight in summary.summaryInsights {
//                            context += "-\(insight.insightContent)\n"
//                        }
//                    }
//                }
//                
//                //all entry summaries
//                context += "\n\nHere are the summaries every entry related to this topic.\n\n"
//                for entry in topic.topicEntries {
//                    context += """
//                        \(entry.entryTitle)\n
//                        \(entry.entrySummary)\n\n
//                    """
//                }
//            }//topic
//            
//            
//        }
//
//        return context
//    }
    
}


// MARK: reusable code
extension ContextGatherer {
    
    
    private static func addGoalInfo(goal: Goal) -> String {
        return """
            a) title: \(goal.goalTitle)
            b) type: \(goal.goalProblemType)
            c) goal: \(goal.goalResolution)
            d) problem statement: \(goal.goalProblemLong)\n\n
        """
    }
    
    // questions answered when creating goal
    private static func getNewGoalContext(goal: Goal, category: Category) -> String {
        var context = """
            What user said about the topic: \n
        """
        
        let goalQuestions = goal.goalQuestions
            .filter { $0.categoryStarter == true }
            .sorted { $0.questionCreatedAt < $1.questionCreatedAt }
        
        context += """
            The topic is about this area of the user's life: \(category.categoryLifeArea)\n
        """
        
        context += getQuestions(goalQuestions)
        
        return context
    }
    
    // Helper function to format questions and answers
    private static func getQuestions(_ questions: [Question]) -> String {
        var result = ""
        for question in questions {
            result += """
                Q: \(question.questionContent)\n
            """
            if question.completed {
                if let questionType = QuestionType(rawValue: question.questionType) {
                    switch questionType {
                    case .singleSelect:
                        result += """
                            A: \(question.questionAnswerSingleSelect)\n
                        """
                    case .multiSelect:
                        result += """
                            A: \(question.questionAnswerMultiSelect)\n
                        """
                    case .open:
                        result += """
                            A: \(question.questionAnswerOpen)\n
                        """
                    }
                } else {
                    result += """
                        Answer not found for this question\n
                    """
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
    
    private static func getTopicsList(topics: [Topic]) -> String {
        let sortedTopics = topics.sorted { $0.topicCreatedAt < $1.topicCreatedAt }
        
        let completedTopics = sortedTopics.filter { $0.topicStatus == TopicStatusItem.completed.rawValue }
        
        let lockedTopics = sortedTopics.filter { $0.topicStatus == TopicStatusItem.locked.rawValue }
        
        var context = ""
        
        if completedTopics.isEmpty {
            context += """
                Complete topics: \n
            """
            context += getTopicsDetails(topics: topics)
        }
        
        if lockedTopics.isEmpty {
            context += """
                Locked topics: \n
            """
            context += getTopicsDetails(topics: topics)
        }
        
        return context
    }
    
    
    // get info on each topic
    private static func getTopicsDetails(topics: [Topic]) -> String {
        var topicsText = ""
            
        for topic in topics {
            topicsText += """
                a) title: \(topic.topicTitle)
                b) status: \(topic.topicStatus)
                c) summary: \(topic.review?.reviewSummary ?? "No summary, step still in progress")\n
            """
        }
        
        return topicsText
    }
    
    // sequence summary list
    private static func getSequenceSummaries(summaries: [SequenceSummary]) -> String {
        guard !summaries.isEmpty else {
            return ""
        }
        var context = """
            Plan summaries:\n
        """
        for summary in summaries {
            context += """
                \(summary.summaryContent)\n
            """
        }
        
        return context
    }
    
    // sequence details
    private static func getSequenceDetails(sequence: Sequence) -> String {
        return """
            a) title: \(sequence.sequenceTitle)
            b) description: \(sequence.sequenceIntent)
            c) objectives: \(sequence.sequenceObjectives)\n\n
        """
    }
    
    // other plans/sequences for same goal
   private static func getOtherSequences(currentSequence: Sequence, goalSequences: [Sequence]) -> String {
        
        let otherPlans = goalSequences.filter { $0.sequenceId != currentSequence.sequenceId}
       
        var context = ""
        
        if !otherPlans.isEmpty {
            
            context += """
                Completed plans for the same topic:\n
            """
            
            for plan in otherPlans {
                context += getSequenceDetails(sequence: plan)
                context += """
                    d) summary: \(plan.sequenceSummaries.first?.summaryContent ?? "No summary available")\n\n
                """
                context += getSequenceRecapAnswers(sequence: plan)
            }
        }
        
       return context
        
    }
    
    private static func getSequenceRecapAnswers(sequence: Sequence) -> String {
        var context = """
            User's answers to questions during the plan retrospective flow: \n
        """
        
        let sequenceQuestions = sequence.sequenceQuestions
            .sorted { $0.questionCreatedAt < $1.questionCreatedAt }
        
        context += getQuestions(sequenceQuestions)
        
        return context
    }
}

