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
    
    static let openAIAssistantIdSection: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_SECTION"] as? String else {
            logger.error("OpenAI section creator assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI section creator assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
    static let openAIAssistantIdSectionSummary: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_SECTION_SUMMARY"] as? String else {
            logger.error("OpenAI section summary assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI section summary assistant ID: \(openAIId)")
       
        return openAIId
    }()
    
}

