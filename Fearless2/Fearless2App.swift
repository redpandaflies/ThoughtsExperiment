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
    let viewModelFactoryMain: ViewModelFactoryMain
    
    init() {
        
        let dataController = DataController()
        
        
        Mixpanel.initialize(token: "d4d86478dfdb268b3b66c023196232f0", trackAutomaticEvents: false, flushInterval: 30)
        
        _dataController = StateObject(wrappedValue: dataController)
        viewModelFactoryMain = ViewModelFactoryMain(dataController: dataController)
        
    }
    
    
    var body: some Scene {
        WindowGroup {
            AppViewsManager()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(viewModelFactoryMain)
                
        }
    }
}
