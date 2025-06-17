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
        
        if selectedAssistant == .newGoal || (selectedAssistant == .planSuggestion && sequence == nil) {
            //get questions answered when creating goal
            context += getNewGoalContext(goal: goal, category: category)
        }
      
        if selectedAssistant == .planSuggestion || selectedAssistant == .sequenceSummary {
            
            // current plan (for plan recap and plan suggestions for existing topic)
            if let sequence = sequence {
                
                let goalSequences = goal.goalSequences.sorted { $0.sequenceCreatedAt < $1.sequenceCreatedAt }
                if goalSequences.count > 1 {
                    context += """
                        - The previous plan didn't fully resolve the topic\n\n
                    """
                }
                
                if selectedAssistant == .sequenceSummary {
                    context += """
                        Create the retrospective for this plan: \(sequence.sequenceTitle).\n
                    """
                    
                } else {
                    context += """
                        The most recent plan: \(sequence.sequenceTitle).\n
                    """
                }
                
                context += """
                    - description: \(sequence.sequenceIntent)
                    - objectives: \(sequence.sequenceObjectives)\n\n
                """
                
                // get plan reflection, if available
                context += getSequenceSummaries(summaries: sequence.sequenceSummaries)
     
                
                // get answers from plan recap flow
                context += getSequenceRecapAnswers(sequence: sequence)
                
                // get steps in current plan
                context += getTopicsList(
                    topics: sequence.sequenceTopics,
                    sendQuestions: false
                )
                
                // other plans for the current goal
                let otherSequences = goalSequences.filter { $0.sequenceId != sequence.sequenceId }
                
                if goalSequences.count > 1 && selectedAssistant != .sequenceSummary {
                    context += getSequences(goalSequences: otherSequences)
                } else if goalSequences.count > 1 {
                    
                    /// for sequence (plan) summary, get the user's answer to the question "what would be most helpful" from the recap for the previous plan
                    if let previousSequence = otherSequences.last {
                        let keyQuestion = previousSequence.sequenceQuestions.filter { $0.questionContent == NewQuestion.questionsNextSequence[3].content }.first
                        
                        context += """
                            Previous plan: \(previousSequence.sequenceTitle)
                            At the end of the previous plan, user said this would be most helpful: \(keyQuestion?.questionAnswerOpen ?? "")
                        """
                    }
                    
                }
                
            }
            
            // Other completed and ongoing goals
//            let fetchedGoals = await dataController.fetchAllGoals()
//            //filter out current goal
//            let remainingGoals = fetchedGoals.filter { $0.goalId != goal.goalId }
//            
//            if remainingGoals.isEmpty {
//                context += """
//                    Here are the user's other completed and ongoing goals:\n
//                """
//                
//                for goal in remainingGoals {
//                    context += """
//                        - goal: \(goal.goalTitle)
//                        - type: \(goal.goalProblemType)
//                        - problem: \(goal.goalProblem)
//                        - resolution: \(goal.goalResolution)\n 
//                    """
//                    
//                    let goalSequences = goal.goalSequences
//                    
//                    context += getSequences(goalSequences: goalSequences)
//                    
//                }
//            }
    
        }

        return context
    }
    
    //for updating topic, topic recaps, topic breaks
    static func gatherContextTopic(dataController: DataController, loggerCoreData: Logger, selectedAssistant: AssistantItem, topic: Topic) async -> String? {
        guard let topic = await dataController.fetchTopic(id: topic.topicId) else {
            loggerCoreData.error("Failed to fetch topic with ID: \(topic.topicId.uuidString)")
               return nil
        }
        
        guard let goal = topic.goal else {
            loggerCoreData.error("Failed to get related goal")
            return nil
        }
        
        let sequence = topic.sequence
        
        // Step the user is requesting questions for
        var context = """
            Current step: \(topic.topicTitle).
            - objective: \(topic.topicDefinition)
            - type: \(topic.topicQuestType). \n\n
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
                Steps in this plan:\n
            """
            context += getTopicsList(topics: sequenceTopics, sendQuestions: selectedAssistant != .topicOverview ? true : false, sendLockedTopics: selectedAssistant == .topic)
            
            // other plans for the current goal
            if selectedAssistant == .topic {
                let otherSequences = goal.goalSequences.filter { $0.sequenceId != sequence.sequenceId }
                
                if !otherSequences.isEmpty {
                    context += getSequences(goalSequences: otherSequences)
                }
            }
        }

        return context
    }
    
    //for daily topic
    static func gatherContextDailyTopic(
        topicRepository: TopicRepository,
        goalRepository: GoalRepository,
        loggerCoreData: Logger,
        selectedAssistant: AssistantItem,
        currentTopic: TopicDaily? = nil
    ) async -> String? {
        
        var context = ""
//        guard let topic = await topicRepository.fetchDailyTopic(id: topic.topicId) else {
//            loggerCoreData.error("Failed to fetch topic with ID: \(topic.topicId.uuidString)")
//               return nil
//        }
        /// all existing daily topics
        if let dailyTopics = await topicRepository.fetchAllDailyTopics() {
            for topic in dailyTopics {
                
                if let newTopic = currentTopic, newTopic.topicId == topic.topicId {
                    context += """
                        You are generating questions for this topic: \(topic.topicTitle).
                        Its theme is \(topic.topicTheme).\n\n
                    """
                    
                    let expectations = topic.topicExpectations.sorted { $0.orderIndex < $1.orderIndex }
                    
                    if !expectations.isEmpty {
                        context += """
                            Here's what the topic should cover: \n
                        """
                        
                        
                        for expectation in expectations {
                            context += """
                                - \(expectation.expectationContent)\n
                            """
                        }
                        
                    }
                    
                } else if topic.topicId == dailyTopics.first?.topicId {
                    context += getDailyTopicBasics(topic)
                    
                    // get recap questions from previous day's daily topic, which asks users what they'd like to focus on next
                    let reflectQuestions = topic.topicQuestions.filter { $0.reflectQuestion == true}
                        context += """
                            What the user said they'd like to focus on for today's topic:\n
                        """
                    if !reflectQuestions.isEmpty {
                       context += getQuestions(reflectQuestions)
                    }
                    
                } else {
                    context += getDailyTopicBasics(topic)
                }
                
                if let recap = topic.review {
                    context += """
                        - summary: \(recap.reviewSummary)\n
                    """
                    
                    let feedback = topic.topicFeedback.sorted { $0.orderIndex < $1.orderIndex }
                    
                    for item in feedback {
                        context += """
                            - \(item.feedbackContent)
                        """
                    }
                }
                
            }
        }
        
        // goals
        let goals = await goalRepository.fetchAllGoals()
        
        /// active topics
        let activeGoals = goals.filter { $0.goalStatus == GoalStatusItem.active.rawValue }
        
        if activeGoals.count > 0 {
            context += """
                Active topics: \n
            """
            
            for goal in activeGoals {
                context += addGoalWithSequences(goal: goal)
            }
        }
            
        /// resolved topics
        let resolvedGoals = goals.filter { $0.goalStatus == GoalStatusItem.completed.rawValue }
        
        if resolvedGoals.count > 0 {
            context += """
                Resolved topics: \n
            """
            
            for goal in resolvedGoals {
                context += addGoalWithSequences(goal: goal)
                
            }
        }
        return context
    }
    
    
    
    // daily topic review
    static func gatherContextDailyTopicRecap(
        topicRepository: TopicRepository,
        loggerCoreData: Logger,
        selectedAssistant: AssistantItem,
        topic: TopicDaily
    ) async -> String? {
        guard let topic = await topicRepository.fetchDailyTopic(id: topic.topicId) else {
            loggerCoreData.error("Failed to fetch topic with ID: \(topic.topicId.uuidString)")
               return nil
        }
        
        // Step the user is requesting questions for
        var context = """
            Topic: \(topic.topicTitle).
            - theme: \(topic.topicTheme)
            - status: \(topic.topicStatus) \n\n
        """
        
        // step questions for topic/step summary
        let questions = topic.topicQuestions
        if !questions.isEmpty {
            context += """
                Answers for questions in this step:\n
            """
            context += getQuestions(questions)
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
            - title: \(goal.goalTitle)
            - type: \(goal.goalProblemType)
            - goal: \(goal.goalResolution)
            - problem statement: \(goal.goalProblem)\n\n
        """
    }
    
   private static func addGoalWithSequences(goal: Goal) -> String {
        var result = ""
        result += addGoalInfo(goal: goal)
        
        for sequence in goal.goalSequences {
            result += getSequenceDetails(sequence: sequence)
            result += getSequenceSummaries(summaries: sequence.sequenceSummaries)
        }
        
        return result
    }
    
    // questions answered when creating goal
    private static func getNewGoalContext(goal: Goal, category: Category) -> String {
       
        let goalQuestions = goal.goalQuestions
            .filter { $0.goalStarter == true }
            .sorted { $0.questionCreatedAt < $1.questionCreatedAt }
        
//        var context = """
//            The topic is about this area of the user's life: \(category.categoryLifeArea)\n
//        """
        
        let context = getQuestions(goalQuestions)
        
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
    
    private static func getTopicsList(topics: [Topic], sendQuestions: Bool, sendLockedTopics: Bool = false) -> String {
        let sortedTopics = topics.sorted { $0.topicCreatedAt < $1.topicCreatedAt }
        
        let completedTopics = sortedTopics.filter { $0.topicStatus == TopicStatusItem.completed.rawValue }
        
        var context = ""
        
        if !completedTopics.isEmpty {
            context += """
                
                Complete steps: \n
            """
            context += getTopicsDetails(topics: completedTopics, sendQuestions: sendQuestions)
        }
        
        if sendLockedTopics {
            let lockedTopics = sortedTopics.filter { $0.topicStatus == TopicStatusItem.locked.rawValue }
            
            if !lockedTopics.isEmpty {
                context += """
                    
                    Locked steps: \n
                """
                context += getTopicsDetails(topics: lockedTopics, sendQuestions: sendQuestions)
            }
        }
        
        return context
    }
    
    
    // get info on each topic
    private static func getTopicsDetails(topics: [Topic], sendQuestions: Bool) -> String {
        var topicsText = ""
            
        for topic in topics {
            let questions = topic.topicQuestions
            
            topicsText += """
                - title: \(topic.topicTitle)
            """
            if sendQuestions && !questions.isEmpty {
                topicsText += """
                    - step questions and answers:\n
                """
                topicsText += getQuestions(topic.topicQuestions)
                
            } else {
                topicsText += """
                    - summary: \(topic.review?.reviewSummary ?? "none, step in progress")\n\n
                """
                
            }
        }
        
        return topicsText
    }
    
    // sequence summary list
    private static func getSequenceSummaries(summaries: [SequenceSummary]) -> String {
        guard !summaries.isEmpty else {
            return ""
        }
        var context = """
            Summary for this plan:\n
        """
        for summary in summaries {
           
            context += """
                - \(summary.summaryContent)\n
            """
        }
        
        return context
    }
    
    // sequence details
    private static func getSequenceDetails(sequence: Sequence) -> String {
        return """
            - title: \(sequence.sequenceTitle)
            - description: \(sequence.sequenceIntent)
            - objectives: \(sequence.sequenceObjectives)\n\n
        """
    }
    
    // other plans/sequences for same goal
   private static func getSequences(goalSequences: [Sequence]) -> String {
       
        var context = ""

        context += """
            Completed plans for the same topic:\n
        """
            
       for sequence in goalSequences {
           context += getSequenceDetails(sequence: sequence)
                
           context += getSequenceSummaries(summaries: sequence.sequenceSummaries)
               
        }
        
       return context
        
    }
    
    private static func getSequenceRecapAnswers(sequence: Sequence) -> String {
        
        let sequenceQuestions = sequence.sequenceQuestions
            .sorted { $0.questionCreatedAt < $1.questionCreatedAt }
        
        if sequenceQuestions.isEmpty {
            return ""
        }
        
        var context = """
            
            User's answers to questions during the plan retrospective flow: \n
        """
        
        context += getQuestions(sequenceQuestions)
        
        return context
    }
    
    // daily topic
    private static func getDailyTopicBasics(_ topic: TopicDaily) -> String {
        var context = """
            Topic: \(topic.topicTitle).
            - theme: \(topic.topicTheme)
            - status: \(topic.topicStatus) \n
        """
        
        return context
    }
    
}

