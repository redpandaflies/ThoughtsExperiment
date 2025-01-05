//
//  TopicDetailViewFooter.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/13/24.
//
import OSLog
import SwiftUI

struct TopicDetailViewFooter: View {
    
    @EnvironmentObject var dataController: DataController
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    
    @Binding var selectedTabTopic: TopicPickerItem
    @Binding var currentTabBar: TabBarType
    @Binding var navigateToTopicDetailView: Bool
    
    let topicId: UUID?
    let screenWidth = UIScreen.current.bounds.width
    let logger = Logger.audioEvents
    
    var body: some View {
           
        HStack {
            Button {
                dismissView()
                
            } label: {
                Image(systemName: "arrow.backward")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.whiteDefault)
                    .frame(width: 30, height: 30)
            }
            
            Spacer()
            
            TopicPickerView(selectedTabTopic: $selectedTabTopic)
            
            Spacer()
            
            Menu {
                Button (role: .destructive) {
                    Task {
                        if let currentTopicId = topicId {
                            await dataController.deleteTopic(id: currentTopicId)
                        }
                    }
                    dismissView()
                    
                } label: {
                    
                    Label("Delete", systemImage: "trash")
                    
                }
                
            } label: {
                Group {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.whiteDefault)
                        .frame(width: 30, height: 30)
                }
            }
            
            
        }//HStack
        .padding(.horizontal)
        .frame(height: 40)
    }
    
    private func dismissView() {
        navigateToTopicDetailView = false
        withAnimation(.snappy(duration: 0.2)) {
            currentTabBar = .home
            selectedTabTopic = .explore
        }
    }
}
