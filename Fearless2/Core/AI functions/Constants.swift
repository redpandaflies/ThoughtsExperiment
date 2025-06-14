//
//  Constants.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//

import Foundation
import OSLog

enum Constants {
    
    private static let infoDictionary: [String: Any]? = Bundle.main.infoDictionary
    
    private static let logger = Logger.launchEvents
    
    static let openAIPartialKey: String = {
        guard let infoDict = infoDictionary,
              let openAIPartialKey = infoDict["OPENAI_PARTIAL_KEY"] as? String else {
            logger.error("OpenAI partial key not available, using placeholder")
            return ""
        }
        
        logger.info("Retrieved OpenAI partial key: \(openAIPartialKey)")
        
        return openAIPartialKey
    }()
    
    static let openAIAssistantIdNewGoal: String = {
        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_NEW_GOAL"] as? String else {
            logger.error("OpenAI new goal assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI new goal assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let openAIAssistantIdSequenceSuggestion: String = {
        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_SEQUENCE_SUGGESTION"] as? String else {
            logger.error("OpenAI plan suggestion assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI plan suggestion assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let openAIAssistantIdTopic: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_TOPIC"] as? String else {
            logger.error("OpenAI topic assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI topic assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let openAIAssistantIdTopicOverview: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_TOPIC_OVERVIEW"] as? String else {
            logger.error("OpenAI topic overview assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI topic overview assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let openAIAssistantIdTopicBreak: String = {
        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_TOPIC_BREAK"] as? String else {
            logger.error("OpenAI topic break assistant ID not available, using placeholder")
            return ""
        }
        
        logger.info("Retrieved OpenAI topic break assistant ID: \(openAIId)")
        
        return openAIId
    }()
    
    static let openAIAssistantIdSequenceSummary: String = {
        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_SEQUENCE_SUMMARY"] as? String else {
            logger.error("OpenAI plan/sequence summary assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI plan/sequence summary assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    // MARK: - Daily topic
    static let openAIAssistantIdTopicDaily: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_TOPIC_DAILY"] as? String else {
            logger.error("OpenAI daily topic assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI daily topic assistant ID: \(openAIId)")
       
        return openAIId
    }()
        
    static let openAIAssistantIdTopicDailyQuestions: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_TOPIC_DAILY_QUESTIONS"] as? String else {
            logger.error("OpenAI daily topic questions assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI daily topic questions assistant ID: \(openAIId)")
       
        return openAIId
    }()
        
    static let openAIAssistantIdTopicDailyRecap: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_TOPIC_DAILY_RECAP"] as? String else {
            logger.error("OpenAI daily topic recap assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI daily topic recap assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    // MARK: - Supabase
    
    static let supabaseURL: URL = {
        guard let infoDict = infoDictionary,
              let databaseURL = infoDict["SUPABASE_URL"] as? String else {
            logger.error("Supabase URL not available, using placeholder")
            return URL(string: "")!
        }
        if FeatureFlags.isStaging {
            logger.info("Retrieved supabaseURL: \(databaseURL)")
        }
        return URL(string: databaseURL) ?? URL(string: "")!
    }()
    
    static let supabaseKey: String = {

        guard let infoDict = infoDictionary,
              let databaseKey = infoDict["SUPABASE_ANON_KEY"] as? String else {
            logger.error("Supabase key not available, using placeholder")
            return ""
        }
        if FeatureFlags.isStaging {
            logger.info("Retrieved supabase key: \(databaseKey)")
        }
        return databaseKey
    }()
    
    // MARK: - Not in use
    static let openAIAssistantIdSectionSummary: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_SECTION_SUMMARY"] as? String else {
            logger.error("OpenAI section summary assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI section summary assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let openAIAssistantIdFocusAreaSummary: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_FOCUS_AREA_SUMMARY"] as? String else {
            logger.error("OpenAI focus area summary assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI focus area summary assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let openAIAssistantIdFocusAreaSuggestions: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_FOCUS_AREA_SUGGESTIONS"] as? String else {
            logger.error("OpenAI section suggestions assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI section suggestions assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let openAIAssistantIdFocusArea: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_FOCUS_AREA"] as? String else {
            logger.error("OpenAI focus area assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI focus area assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let openAIAssistantIdEntry: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_ENTRY"] as? String else {
            logger.error("OpenAI entry assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI entry assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let openAIAssistantIdUnderstand: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_UNDERSTAND"] as? String else {
            logger.error("OpenAI understand assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI understand assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let stabilityPartialKey: String = {
        guard let infoDict = infoDictionary,
              let stabilityPartialKey = infoDict["STABILITY_PARTIAL_KEY"] as? String else {
            logger.error("Stability partial key not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved stability partial key: \(stabilityPartialKey)")
        
        return stabilityPartialKey
    }()
    
    static let openAIAssistantIdTopicSuggestions: String = {
        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_TOPIC_SUGGESTIONS"] as? String else {
            logger.error("OpenAI topic suggestions assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI topic suggestions assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let openAIAssistantIdTopicSuggestions2: String = {
        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_TOPIC_SUGGESTIONS2"] as? String else {
            logger.error("OpenAI topic suggestions (new) assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI topic suggestions assistant ID: \(openAIId)")
       
        return openAIId
    }()
}
