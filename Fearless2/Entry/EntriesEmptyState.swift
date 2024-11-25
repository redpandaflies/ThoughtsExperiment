//
//  EntriesEmptyState.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/24/24.
//

import SwiftUI

struct EntriesEmptyState: View {
    @ObservedObject var transcriptionViewModel: TranscriptionViewModel
    @Binding var showRecordingView: Bool
    
    var body: some View {
        VStack (spacing: 30) {
            Text("Log any thoughts you have\non this topic")
                .multilineTextAlignment(.center)
                .font(.system(size: 22))
                .foregroundStyle(Color.white)
            
            WhyBox(text: "This helps you uncover more insights and\nshape your path.", backgroundColor: AppColors.black2)
                .padding(.bottom, 50)
            
            StartRecordingButton(transcriptionViewModel: transcriptionViewModel, showRecordingView: $showRecordingView)
        }
    }
}
