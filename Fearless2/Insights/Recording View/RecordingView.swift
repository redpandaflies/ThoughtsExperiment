////
////  RecordingView.swift
////  Fearless2
////
////  Created by Yue Deng-Wu on 11/13/24.
////
//import OSLog
//import SwiftUI
//
//struct RecordingView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var selectedTab: Int = 0
//    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
//    
//    let categoryEmoji: String
//    let topic: Topic
//    let logger = Logger.audioEvents
//    
//    var body: some View {
//        
//        VStack (spacing: 10) {
//                
//            header()
//
//            switch selectedTab {
//                case 0:
//                    RecordingStartView(transcriptionViewModel: transcriptionViewModel, selectedTab: $selectedTab, topic: topic)
//                    
//                default:
//                    RecordingLoadingAnimation()
//            }
//
//            }//VStack
//            .padding()
//            .padding(.bottom, 20)
//        
//    }
//    
//    private func header() -> some View {
//        HStack {
//           
//            Image(systemName: "xmark.circle.fill")
//                .font(.system(size: 30))
//                .foregroundStyle(Color.clear)
//            
//            Spacer()
//            
//            HStack {
//                Image(systemName: "record.circle")
//                    .font(.system(size: 14))
//                    .foregroundStyle(AppColors.whiteDefault)
//                    .textCase(.uppercase)
//                    .opacity(0.5)
//                
//                Text("Recording")
//                    .font(.system(size: 14))
//                    .foregroundStyle(AppColors.whiteDefault)
//                    .textCase(.uppercase)
//                    .opacity(0.5)
//            }
//            
//            
//            Spacer()
//            
//            Button {
//                cancelRecording()
//            } label: {
//                Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 30))
//                    .foregroundStyle(AppColors.whiteDefault)
//                    .opacity(0.6)
//                    
//            }
//        }//HStack
//    }
//    
//    private func cancelRecording() {
//        dismiss()
//        
//        Task {
//            
//          let cancelledRecording = await transcriptionViewModel.cancelRecording()
//            
//           if cancelledRecording {
//               logger.info("Cancelled recording")
//           } else {
//               logger.error("Failed to cancel recording")
//           }
//        }
//    }
//}
//
//struct RecordingStartView: View {
//    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
//    @State private var playAnimation = false
//    
//    @Binding var selectedTab: Int
//    let topic: Topic
//    let logger = Logger.audioEvents
//    
//    var body: some View {
//        VStack (spacing: 10){
//            Text("Talk freely about this topic.")
//                .multilineTextAlignment(.center)
//                .font(.system(size: 20))
//                .foregroundStyle(AppColors.yellow1)
//            
//            Spacer()
//            
//            Group {
//                Image(systemName: playAnimation ? "stop.fill" : "circle.fill")
//                    .font(.system(size: 30))
//                    .foregroundStyle(Color.black)
//                    .frame(width: 100, height: 100)
//                    .contentTransition(.symbolEffect(.replace.offUp.byLayer))
//                    .background {
//                        Circle()
//                            .fill(AppColors.yellow1)
//                    }
//            }
//            .contentShape(Circle())
//            .padding(.bottom, 100)
//            .onTapGesture {
//                handleRecordingButtonAction(recordingAction: .newEntry)
//            }
//            .onAppear {
//                playAnimation = true
//            }
//            
//            Text("Sometimes it helps to simply talk out loud\nabout the things on your mind.")
//                .font(.system(size: 12))
//                .foregroundStyle(AppColors.whiteDefault)
//                .opacity(0.5)
//        }
//        .padding(.bottom, 30)
//    }
//    
//    private func handleRecordingButtonAction(recordingAction: RecordingAction) {
//        playAnimation = false
//        selectedTab += 1
//        
//        Task {
//           
//            //process recording and send to AI
//            let processedRecording = await transcriptionViewModel.recordingButtonClick(action: recordingAction, topic: topic)
//            
//            if processedRecording {
//                logger.info("Stopped and processed recording")
//            } else {
//                logger.error("Failed to process recording")
//            }
//            
//        }
//    }
//}
