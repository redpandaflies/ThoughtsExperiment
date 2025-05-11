//
//  SettingsView.swift
//  TrueBlob
//
//  Created by Yue Deng-Wu on 12/20/23.
//
import Mixpanel
import SwiftUI


struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController

    @State private var showStartOverAlert: Bool = false
    @State private var playHapticEffect: Int = 0
    @State private var navigateToNotificationsView: Bool = false
    
    let backgroundColor: Color
    
    @AppStorage("currentAppView") var currentAppView: Int = 0
    @AppStorage("unlockNewCategory") var newCategory: Bool = false
    @AppStorage("discoveredFirstCategory") var discoveredFirstCategory: Bool = false
    @AppStorage("discoveredFirstFocusArea") var firstFocusArea: Bool = false
    @AppStorage("currentCategory") var currentCategory: Int = 0
    @AppStorage("showTopics") var showTopics: Bool = false
    
    var body: some View {
        
        NavigationStack {
            VStack (spacing: 15) {
                
                Image("spinnerSilver")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70)
                    .blendMode(.plusLighter)
                
                Text("Preferences")
                    .font(.system(size: 25, design: .serif))
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.bottom, 30)
              
                SettingsLabel(iconName: "chevron.right", text: "Reminders")
                    .onTapGesture {
                        playHapticEffect += 1
                        navigateToNotificationsView = true
                      
                    }
                    .sensoryFeedback(.selection, trigger: playHapticEffect)
                    .navigationDestination(isPresented: $navigateToNotificationsView) {
                        NotificationSettingsView(backgroundColor: backgroundColor)
                            .toolbarRole(.editor) //removes the word "back" in the back button
                    }
                
                ShareLink (
                    item: URL(string: "https://testflight.apple.com/join/GMHjFVf1")!
                ) {
                    
                    SettingsLabel(iconName: "paperplane.fill", text: "Send this to a friend")
                }
                .background {
                    Button {
                        playHapticEffect += 1
                        DispatchQueue.global(qos: .background).async {
                            Mixpanel.mainInstance().track(event: "Refer friend")
                        }
                    } label: {
                        EmptyView()
                    }
                    .sensoryFeedback(.selection, trigger: playHapticEffect)
                }
                
                SettingsLabel(iconName: "arrow.counterclockwise", text: "Start over")
                    .onTapGesture {
                        playHapticEffect += 1
                        showStartOverAlert = true
                    }
                    .sensoryFeedback(.selection, trigger: playHapticEffect)
                
                
            }//VStack
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background {
                BackgroundPrimary(backgroundColor: backgroundColor)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    XmarkToolbarItem(action: {
                        dismiss()
                    })
                }
            }
        }//NavigationStack
        .tint(AppColors.textPrimary.opacity(0.7))//sets the back button on navigationlink views to white
        .environment(\.colorScheme, .dark)
        .alert("⚠️\nAre you sure you want to start over?", isPresented: $showStartOverAlert) {
            Button("Start over", role: .destructive) {
                startOver()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All your existing data will be lost.")
        }
        
    }//body
    
//    private func dividerLine() -> some View {
//        Rectangle()
//            .fill(AppColors.dividerPrimary.opacity(0.2))
//            .frame(maxWidth: .infinity)
//            .frame(height: 1)
//            .shadow(color: AppColors.dividerShadow.opacity(0.05), radius: 0, x: 0, y: 1)
//    }
    
    private func startOver() {
        dismiss()
        
        //reset all appstorage and cloudstorage vars
        currentCategory = 0
        currentAppView = 0
//        newCategory = false
//        showTopics = false
//        discoveredFirstCategory = false // commented out temporarily, allow users to start over elegantly without going through onboarding
//        firstFocusArea = false
        
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
  
    var body: some View {
        HStack {
           
            Text(text)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(AppColors.textPrimary)
          
            Spacer()
            
            Image(systemName: iconName)
                .font(.system(size: 19, weight: .regular))
                .foregroundStyle(AppColors.textPrimary.opacity(0.8))
          
        }//HStack
        .padding(.horizontal, 15)
        .padding(.vertical, 16.5)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                .fill(AppColors.boxGrey1.opacity(0.3))
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 3)
                .blendMode(.colorDodge)
        }
      
    }
}





