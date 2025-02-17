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
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    
    @State private var showDeleteTopicAlert: Bool = false
    
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var currentTabBar: TabBarType
    @Binding var navigateToTopicDetailView: Bool
    
    let topic: Topic?
    let screenWidth = UIScreen.current.bounds.width
    
    var body: some View {
           
        HStack {
            Button {
                
            } label: {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.clear)
                    .frame(width: 30, height: 30)
            }
            
            Spacer()
            
            TopicPickerView(selectedTabTopic: $selectedTabTopic)
            
            Spacer()
            
            Menu {
                
                Button (role: .destructive) {
                    showDeleteTopicAlert = true
                    
                } label: {
                
                    Label("Delete", systemImage: "trash")
                }
                
                if let currentTopic = topic, currentTopic.topicStatus == TopicStatusItem.archived.rawValue {
                    
                    Button {
                        updateTopicStatus(newStatus: .active)
                    } label: {
                        Label("Unarchive", systemImage: "arrow.up.bin")
                    }
                } else {
                    Button {
                        updateTopicStatus(newStatus: .archived)
                        
                    } label: {
                        Label("Archive", systemImage: "archivebox")
                    }
                }
                
                
            } label: {
                
                Image(systemName: "ellipsis")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.whiteDefault.opacity(0.7))
                    .frame(width: 30, height: 30)
                
            }
            
            
        }//HStack
        .padding(.horizontal)
        .frame(height: 40)
        .alert("Are you sure you want to delete this topic?", isPresented: $showDeleteTopicAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Yes", role: .destructive) {
                deleteTopic()
            }
        } message: {
            Text("This will erase all data for the topic.")
        }
    }
    
    private func dismissView() {
        navigateToTopicDetailView = false
        withAnimation(.snappy(duration: 0.2)) {
            currentTabBar = .home
            selectedTabTopic = .explore
        }
    }
    
    private func deleteTopic() {
        Task {
            if let currentTopicId = topic?.topicId {
                await dataController.deleteTopic(id: currentTopicId)
            }
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: "Deleted topic")
            }
        }
        dismissView()
    }
    
    private func updateTopicStatus(newStatus: TopicStatusItem) {
        Task {
            if let currentTopicId = topic?.topicId {
                await dataController.updateTopicStatus(id: currentTopicId, item: newStatus)
            }
            
            var mixpanelEvent: String {
                return newStatus == .active ? "Unarchived topic" : "Archived topic"
            }
            
            DispatchQueue.global(qos: .background).async {
                Mixpanel.mainInstance().track(event: mixpanelEvent)
            }

        }
        
        dismissView()
    }

}
