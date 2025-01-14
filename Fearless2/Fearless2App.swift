//
//  Fearless2App.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 9/30/24.
//
import Mixpanel
import SwiftUI

@main
struct Fearless2App: App {
    @StateObject var dataController: DataController
    @StateObject var openAISwiftService: OpenAISwiftService
    
    init() {
        
        let dataController = DataController()
        let openAISwiftService = OpenAISwiftService(dataController: dataController)
        
        Mixpanel.initialize(token: "d4d86478dfdb268b3b66c023196232f0", trackAutomaticEvents: false)
        
        _dataController = StateObject(wrappedValue: dataController)
        _openAISwiftService = StateObject(wrappedValue: openAISwiftService)
        
    }
    
    
    var body: some Scene {
        WindowGroup {
            AppViewsManager(dataController: dataController, openAISwiftService: openAISwiftService)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(openAISwiftService)
        }
    }
}
