//
//  CustomErrors.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 1/30/25.
//

import Foundation

// OpenAI request errors
enum OpenAIError: LocalizedError {
    case missingRequiredField(String)
    case requestFailed(Error, String)
    case runIncomplete(Error? = nil, String? = nil)
    case streamingTimeout
    
    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let context):
            return "Required field not found: \(context)"
        case .requestFailed(let error, let context):
            return "Request failed: \(error.localizedDescription). \(context)"
        case .runIncomplete(let error, let context):
            if let error = error {
                return "Run incomplete: \(error.localizedDescription)"
            } else if let context = context {
                return "Run incomplete: \(context)"
            } else {
                return "Run incomplete: No additional error details available."
            }
        case .streamingTimeout:
            return "Streamed run timed out."
      
        }
    }
}

// Coredata errors
enum CoreDataError: LocalizedError {
    case coreDataError(Error)
    case saveFailed(Error, String)
    case objectNotFound(String) // Include context about what wasn't found
    
    var errorDescription: String? {
        switch self {
        case .coreDataError(let error):
            return "CoreData error: \(error.localizedDescription)"
        case .saveFailed(let error, let context):
            return "Failed to save changes: \(error.localizedDescription). \(context)"
        case .objectNotFound(let context):
            return "Could not find: \(context)"
       
        }
        
    }
}

// Errors for decoding JSON from OpenAI
enum ProcessingError: LocalizedError {
    case missingRequiredField(String)
    case decodingError(String)
    case processingFailed(Error? = nil)
    case focusAreaProcessingFailed(Error)
    case topicProcessingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let context):
            return "Required field not found: \(context)"
        case .decodingError(let context):
            return "Failed to decode response for \(context)" //failed to decode JSON
        case .processingFailed(let error): //used in view model
            if let error = error {
                return "Failed to process JSON: \(error.localizedDescription)"
            } else {
                return "Failed to process JSON"
            }
        case .focusAreaProcessingFailed(let error):
            return "Failed to process focus area: \(error.localizedDescription)"
        case .topicProcessingFailed(let error):
            return "Failed to process topic: \(error.localizedDescription)"
        }
    }
}

// Errors for gathering context to send to OpenAI
enum ContextError: LocalizedError {
    case missingRequiredField(String)
    case noContextFound(String)
    
    var errorDescription: String? {
        switch self {
        case .missingRequiredField(let context):
            return "Required field not found: \(context)"
        case .noContextFound(let context):
            return "Failed to gather context for \(context)"
        }
    }
}

// Errors for authentication
enum AuthError: LocalizedError {
    case authenticationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed(let underlying):
            return "Authentication failed: \(underlying.localizedDescription)"
        }
    }
}
