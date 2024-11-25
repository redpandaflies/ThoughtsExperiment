//
//  StartRecordingButton.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/24/24.
//
import OSLog
import SwiftUI

struct StartRecordingButton: View {
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    @Binding var showRecordingView: Bool
    let logger = Logger.audioEvents
    
    
    var body: some View {
        Group {
            Image(systemName: "waveform")
                .font(.system(size: 27))
                .foregroundStyle(Color.black)
                .frame(width: 120, height: 120)
                .background {
                    Circle()
                        .fill(AppColors.yellow1)
                }
        }
        .contentShape(Circle())
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
    }
}
