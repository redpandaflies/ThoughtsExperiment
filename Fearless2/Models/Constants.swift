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
    
    static let openAIAssistantIdEntry: String = {

        guard let infoDict = infoDictionary,
              let openAIId = infoDict["OPENAI_ASSISTANT_ID_ENTRY"] as? String else {
            logger.error("OpenAI entry assistant ID not available, using placeholder")
            return ""
        }
       
        logger.info("Retrieved OpenAI entry assistant ID: \(openAIId)")
       
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
}

