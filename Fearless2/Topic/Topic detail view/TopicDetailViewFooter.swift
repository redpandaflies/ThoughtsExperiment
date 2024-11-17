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
    
    @Binding var showRecordingView: Bool
    
    let topicId: UUID?
    let screenWidth = UIScreen.current.bounds.width
    let logger = Logger.audioEvents
    
    var body: some View {
        VStack {
            Spacer()
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
                
                HStack {
                    
                    Group {
                        Image(systemName: "waveform")
                            .font(.system(size: 20))
                            .foregroundStyle(Color.black)
                            .padding(.horizontal, 6)
                            .padding(.leading, 10)
                    }
                    .onTapGesture {
                        Task {
                            
                           let startRecording = await transcriptionViewModel.recordingButtonClick(action: .newEntry)
                            
                            if startRecording {
                                logger.info("Started recording")
                            } else {
                                logger.error("Failed to start recording")
                                return
                            }
                            
                            showRecordingView = true
                        }
                    }
                    
                    Rectangle()
                        .frame(width: 1, height: 35)
                        .foregroundStyle(AppColors.footerDivider)
                    
                    Image(systemName: "map.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 6)
                        .padding(.trailing, 10)
                    
                }
                .padding(.vertical, 3)
               
                .background {
                    Capsule(style: .continuous)
                        .fill(AppColors.categoryYellow)
                }
                
                Spacer()
                
                Menu {
                    Button (role: .destructive) {
                        Task {
                            if let currentTopicId = topicId {
                                await dataController.deleteTopic(id: currentTopicId)
                            }
                        }
                        
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
            .padding(.horizontal, 20)
            .frame(width: screenWidth)
           
            .background {
                Rectangle()
                    .fill(Color.black)
            }
            
        }//VStack
        .ignoresSafeArea(.all)
    }
}
