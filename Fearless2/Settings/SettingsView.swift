//
//  SettingsView.swift
//  TrueBlob
//
//  Created by Yue Deng-Wu on 12/20/23.
//
import CloudStorage
import SwiftUI


struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController

    @State private var showStartOverAlert: Bool = false
    
    @CloudStorage("currentAppView") var currentAppView: Int = 0
    @CloudStorage("unlockNewCategory") var newCategory: Bool = false
    @CloudStorage("discoveredFirstCategory") var discoveredFirstCategory: Bool = false
    @CloudStorage("discoveredFirstFocusArea") var firstFocusArea: Bool = false
    @AppStorage("currentCategory") var currentCategory: Int = 0
    @AppStorage("showTopics") var showTopics: Bool = false
    
    var body: some View {
        
        NavigationStack {
            VStack {
                List {
                    
                    SwiftUI.Section (header: SectionHeader(text: "Account")
                    ) {
                        Button( action: {
                            showStartOverAlert = true
                        }) {
                            SettingsLabel(iconName: "arrow.counterclockwise", text: "Start over", redText: true)
                        }
                    }

                } //List
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .environment(\.colorScheme, .dark)
            }//VStack
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    XmarkToolbarItem()
                }
            }
        }//NavigationStack
        .tint(Color.black)//sets the back button on navigationlink views to black
        .alert("⚠️\nAre you sure you want to start over?", isPresented: $showStartOverAlert) {
            Button("Start over", role: .destructive) {
                startOver()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All your existing data will be lost.")
        }
        
    }//body
    
    private func startOver() {
        dismiss()
        
        //reset all appstorage and cloudstorage vars
        currentCategory = 0
        currentAppView = 0
        newCategory = false
        showTopics = false
        discoveredFirstCategory = false
        firstFocusArea = false
        
        //delete all data
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Task {
                await dataController.deleteAll()
                await dataController.resetPoints()
            }
        }
        
    }
    
}

struct SectionHeader: View {
    
    var text: String
    
    var body: some View {
        Text(text)
            .padding(.leading, -15)
            .foregroundStyle(AppColors.textPrimary)
            .opacity(0.7)
    }
}

struct SettingsLabel: View {
    var iconName: String
    var text: String
    var subText: String? = nil
    var longIcon: Bool? = nil
    var redText: Bool? = nil
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.footnote)
                .fontWeight(.regular)
                .foregroundStyle((redText ?? false) ? Color.red : AppColors.textPrimary)
                .padding(.trailing, longIcon == nil ? 3 : 0)
                .padding(.leading, longIcon == nil ? 0 : -2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundStyle((redText ?? false) ? Color.red : AppColors.textPrimary)
                
                if let subText = subText {
                    Text(subText)
                        .font(.caption2)
                        .fontWeight(.regular)
                        .foregroundStyle(AppColors.textPrimary)
                        .opacity(0.5)
                }
            }
            Spacer()
        }
        .frame(height: subText == nil ? 30 : 40)
    }
}





