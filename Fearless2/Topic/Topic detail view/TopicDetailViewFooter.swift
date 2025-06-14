//
//  TopicDetailViewFooter.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/13/24.
//
import Mixpanel
import SwiftUI

struct TopicDetailViewFooter: View {
    
    @EnvironmentObject var dataController: DataController
    
    @State private var showDeleteTopicAlert: Bool = false
    
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var currentTabBar: TabBarType
    @Binding var navigateToTopicDetailView: Bool
    
    let topic: Topic?
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
           
        HStack {
           
            Image(systemName: "arrow.backward")
                .font(.system(size: 20))
                .foregroundStyle(Color.clear)
                .frame(width: 30, height: 30)
          
            Spacer()
            
            TopicPickerView(selectedTabTopic: $selectedTabTopic)
            
            Spacer()
            
           
            Menu {
                
                Button (role: .destructive) {
                    showDeleteTopicAlert = true
                    
                } label: {
                    
                    Label("Abandon quest", systemImage: "trash")
                }
                
                //                if let currentTopic = topic, currentTopic.topicStatus == TopicStatusItem.archived.rawValue {
                //
                //                    Button {
                //                        updateTopicStatus(newStatus: .active)
                //                    } label: {
                //                        Label("Unarchive", systemImage: "arrow.up.bin")
                //                    }
                //                } else {
                //                    Button {
                //                        updateTopicStatus(newStatus: .archived)
                //
                //                    } label: {
                //                        Label("Archive", systemImage: "archivebox")
                //                    }
                //                }
                
                
            } label: {
                
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                    .frame(width: 30, height: 30)
                    .opacity(topic?.completed != true ? 1 : 0)
                
            }
            
            
            
        }//HStack
        .padding(.horizontal)
        .frame(height: 40)
        .alert("Are you sure you want to abort this quest?", isPresented: $showDeleteTopicAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Yes", role: .destructive) {
                deleteTopic()
            }
        } message: {
            Text("You'll lose all content for this quest.")
        }
        .onChange(of: currentTabBar) {
            var event: String
            
            switch selectedTabTopic {
            case .paths:
                event = "Switched to paths tab"
            case .chronicles:
                event = "Switched to chronicles tab"
            }
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: event)
            }
        }
    }
    
    private func dismissView() {
        navigateToTopicDetailView = false
        withAnimation(.snappy(duration: 0.2)) {
            currentTabBar = .home
            selectedTabTopic = .paths
        }
    }
    
    private func deleteTopic() {
        
        if let currentTopicId = topic?.topicId {
           
            Task {
                await dataController.deleteTopic(id: currentTopicId)
                
                // Ensure dismiss happens after deletion
                await MainActor.run {
                    dismissView()
                }
                
                DispatchQueue.global(qos: .background).async {
                    Mixpanel.mainInstance().track(event: "Abandoned quest")
                }
            }
            
        }
       
        
    }
    
    private func updateTopicStatus(newStatus: TopicStatusItem) {
       
        if let currentTopicId = topic?.topicId {
            Task {
            await dataController.updateTopicStatus(id: currentTopicId, item: newStatus)
                
                await MainActor.run {
                    dismissView()
                }
                
                var mixpanelEvent: String {
                    return newStatus == .active ? "Unarchived quest" : "Archived quest"
                }
                
                DispatchQueue.global(qos: .background).async {
                    Mixpanel.mainInstance().track(event: mixpanelEvent)
                }
            }
        }
       
    }

}
