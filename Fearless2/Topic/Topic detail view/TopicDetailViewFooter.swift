//
//  TopicDetailViewFooter.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/13/24.
//
import OSLog
import SwiftUI

struct TopicDetailViewFooter: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataController: DataController
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    
    @Binding var selectedTab: TopicPickerItem
 
    
    let topicId: UUID?
    let screenWidth = UIScreen.current.bounds.width
    let logger = Logger.audioEvents
    
    var body: some View {
        VStack {
           
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.whiteDefault)
                        .frame(width: 30, height: 30)
                }
                
                Spacer()
                
                TopicPickerView(selectedTab: $selectedTab)
                
                Spacer()
                
                Menu {
                    Button (role: .destructive) {
                        Task {
                            if let currentTopicId = topicId {
                                await dataController.deleteTopic(id: currentTopicId)
                            }
                        }
                        dismiss()
                        
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
            .padding(.bottom, 25)
            .padding()
            .frame(width: screenWidth)
            .background {
                Rectangle()
                    .fill(AppColors.topicFooterBackground)
            }
            
        }//VStack
        
    }
}
