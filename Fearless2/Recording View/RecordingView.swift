//
//  RecordingView.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/13/24.
//
import OSLog
import SwiftUI

struct RecordingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab: Int = 0
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    
    let categoryEmoji: String
    let topic: Topic
    let logger = Logger.audioEvents
    
    var body: some View {
        
        VStack (spacing: 10) {
                
                HStack {
                    
                    Spacer()
                    
                    Button {
                        cancelRecording()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.white)
                            .opacity(0.6)
                            
                    }
                    
                }
                
                Image(systemName: categoryEmoji)
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.whiteDefault)
                    .symbolRenderingMode(.monochrome)
                
                Text(topic.topicTitle)
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.whiteDefault)
                
                Spacer()
            
            switch selectedTab {
                case 0:
                RecordingStartView(transcriptionViewModel: transcriptionViewModel, selectedTab: $selectedTab, topic: topic)
                    
                default:
                    RecordingLoadingAnimation()
            }

            }//VStack
            .padding()
            .padding(.bottom, 20)
        
    }
    
    private func cancelRecording() {
        Task {
            dismiss()
          let cancelledRecording = await transcriptionViewModel.cancelRecording()
            
           if cancelledRecording {
               logger.info("Cancelled recording")
           } else {
               logger.error("Failed to cancel recording")
           }
        }
    }
}

struct RecordingStartView: View {
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    @State private var playAnimation = false
    
    @Binding var selectedTab: Int
    let topic: Topic
    let logger = Logger.audioEvents
    
    var body: some View {
        VStack (spacing: 10){
            Text("Talk freely about\nanything related to\nthis topic.")
                .multilineTextAlignment(.center)
                .font(.system(size: 25))
                .foregroundStyle(AppColors.categoryYellow)
            
            Text("For up to 5 minutes")
                .font(.system(size: 15))
                .foregroundStyle(AppColors.whiteDefault)
                .textCase(.uppercase)
            
            Spacer()
            
            Group {
                Image(systemName: "waveform")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.black)
                    .frame(width: 140, height: 140)
                    .symbolEffect(.variableColor.iterative.dimInactiveLayers.nonReversing, options: .speed(0.5), isActive: playAnimation)
                    .background {
                        Circle()
                            .fill(AppColors.categoryYellow)
                    }
            }
            .contentShape(Circle())
            .onTapGesture {
                handleRecordingButtonAction(recordingAction: .newEntry)
            }
            .onAppear {
                playAnimation = true
            }
        }
    }
    
    private func handleRecordingButtonAction(recordingAction: RecordingAction) {
        playAnimation = false
        selectedTab += 1
        
        Task {
           
            //process recording and send to AI
            let processedRecording = await transcriptionViewModel.recordingButtonClick(action: recordingAction, topic: topic)
            
            if processedRecording {
                logger.info("Stopped and processed recording")
            } else {
                logger.error("Failed to process recording")
            }
            
        }
    }
}
