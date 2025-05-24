//
//  Logger+Extension.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 10/2/24.
//

import Foundation
import OSLog

extension Logger {
    static let subsystem = Bundle.main.bundleIdentifier!
    
    static let launchEvents = Logger(subsystem: subsystem, category: "launchEvents")
    static let openAIEvents = Logger(subsystem: subsystem, category: "openAIEvents")
    static let coreDataEvents = Logger(subsystem: subsystem, category: "coreDataEvents")
    static let audioEvents = Logger(subsystem: subsystem, category: "audioEvents")
    static let fileManagerEvents = Logger(subsystem: subsystem, category: "fileManagerEvents")
    static let stabilityEvents = Logger(subsystem: subsystem, category: "stabilityEvents")
    static let uiEvents = Logger(subsystem: subsystem, category: "uiEvents")
    static let mixpanelEvents = Logger(subsystem: subsystem, category: "mixpanelEvents")
    static let notificationEvents = Logger(subsystem: subsystem, category: "notificationEvents")
    static let supabaseEvents = Logger(subsystem: subsystem, category: "supabaseEvents")
    static let authEvents = Logger(subsystem: subsystem, category: "authEvents")
}
