//
//  TranscriptionViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/12/24.
//

import Combine
import Foundation
import OSLog
import CoreData

@MainActor
final class TranscriptionViewModel: ObservableObject {
    
    @Published var recordingState: RecordingState = .idle
    @Published var showRetryButton: Bool = false // used to show/hide the banner in the UI.
    @Published var newEntryId: UUID? = nil
    
    private var openAISwiftService: OpenAISwiftService
    private let dataController: DataController
    private var recordingCompletion: ((Result<Data, Error>) -> Void)?
    let loggerAudio = Logger.audioEvents
    let loggerCoreData = Logger.coreDataEvents
    
    let transcriptionReadySubject = PassthroughSubject<(UUID, UUID, String), Never>()
    
    init(openAISwiftService: OpenAISwiftService, dataController: DataController) {
        self.openAISwiftService = openAISwiftService
        self.dataController = dataController
    }
    
    enum RecordingState {
        case idle
        case recording
        case transcribing
    }
    
    func recordingButtonClick(action: RecordingAction, topic: Topic? = nil) async -> Bool {
        switch recordingState {
            
        case .idle:
            return await startRecording()
            
        case .recording:
            return await stopAndTranscribe(action: action, topic: topic)
            
        case .transcribing:
            //            print("Transcribing in progress")
            return false
        }
    }

    
    func startRecording() async -> Bool {
      
        self.newEntryId = nil
        
        
        do {
            let newId = try await AudioRecorder.shared.startRecording()
            
            self.recordingState = .recording
            self.newEntryId = newId
            
            return true
        } catch {
            
            self.recordingState = .idle
            self.loggerAudio.error("Failed to set up recording: \(error.localizedDescription)")
            return false
        }
    }
    
    func stopAndTranscribe(action: RecordingAction, topic: Topic?  = nil) async -> Bool {

        do {
            let data = try await stopRecordingAsync()
            return await sendRecording(data: data, action: action, topic: topic)
        } catch {
            self.loggerAudio.error("Failed to send recording: \(error.localizedDescription)")
          
            self.recordingState = .idle
            self.showRetryButton = true
            
            return false
        }
    }
    
    private func stopRecordingAsync() async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            AudioRecorder.shared.stopRecording { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }

                // Ensure the continuation is not resumed more than once
                self.recordingCompletion = nil
            }
        }
    }
    
    func cancelRecording() async -> Bool {
        
        do {
            let _ = try await stopRecordingAsync()
            self.recordingState = .idle
            return true
        } catch {
            self.loggerAudio.error("Failed to cancel recording: \(error.localizedDescription)")
           
            self.recordingState = .idle
            
            return false
        }
    }
    
    func sendRecording(data: Data, action: RecordingAction, topic: Topic? = nil, question: String? = nil) async -> Bool {
        
        recordingState = .transcribing
        
        var success = false
        
        switch action {
            case .newEntry:
                
                guard let entryId = newEntryId else {
                    loggerAudio.error("New Entry ID is missing.")
                    recordingState = .idle
                    return false
                }
                
                let newEntryIdString = entryId.uuidString
                let transcriptResult = await openAISwiftService.getTranscript(newEntryId: newEntryIdString, data: data)
                
                
                if let newTranscript = transcriptResult {
                    guard let currentTopic = topic else {
                        loggerAudio.error("Topic is missing.")
                        recordingState = .idle
                        
                        return false
                    }
                        success = true
                        
                    await saveTranscript(topic: currentTopic, entryId: entryId, transcript: newTranscript)
                    loggerAudio.info("Received Transcript: \(newTranscript)")
                    let currentTopicId = currentTopic.topicId
                    transcriptionReadySubject.send((currentTopicId, entryId, newTranscript))
                    
                } else {
                    loggerAudio.error("No transcription found.")
                    success = false
                }
        }
       
            recordingState = .idle
        
            return success
    }
    
    @MainActor
    private func saveTranscript(topic: Topic, entryId: UUID, transcript: String) async {
        let context = self.dataController.container.viewContext
        
        await context.perform {
                
                let entry = Entry(context: context)
                entry.entryId = entryId
                entry.createdAt = getCurrentTimeString()
                entry.entryTranscript = transcript
                topic.addToEntries(entry)

            do {
                try context.save()
            } catch {
                self.loggerCoreData.error("Error saving topic: \(error.localizedDescription)")
            }
        }
        
    }
    
}

enum RecordingAction: Int, CaseIterable {
    case newEntry
    
    func footnoteIcon() -> String {
        switch self {
        case .newEntry:
            return "lock.fill"
        }
    }
    
    func footnoteText() -> String {
        switch self {
        case .newEntry:
            return "Only you can see your entries."
        }
    }
    
}
