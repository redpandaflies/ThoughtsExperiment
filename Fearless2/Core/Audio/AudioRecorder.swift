//
//  AudioRecorder.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 11/12/24.
//

import Foundation
import AVFoundation
import OSLog


final class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var recordingCompletion: ((Result<Data, Error>) -> Void)?
    
   var currentRecordingURL: String?
    let logger = Logger.audioEvents

    static let shared = AudioRecorder()
    private override init() {}
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    enum AudioRecorderError: Error, LocalizedError {
        case recordingPermissionDenied
        case setupFailed
        case noActiveRecording
        case recordingFailed

        var errorDescription: String? {
            switch self {
            case .recordingPermissionDenied:
                return "Recording permission not granted."
            case .setupFailed:
                return "Failed to set up audio session."
            case .noActiveRecording:
                return "No active recording to stop."
            case .recordingFailed:
                return "Recording failed to complete."
            }
        }
    }
   
   func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    
    func setupAudioSession() async throws {
        let audioSession = AVAudioSession.sharedInstance()
        
        try audioSession.setCategory(.playAndRecord, mode: .default, options: .allowBluetooth)
        
        try audioSession.setActive(true)
    }

    func startRecording() async throws -> UUID? {
        let newEntryId = UUID()
        let relativePath = "recording\(newEntryId.uuidString).m4a"
        let audioFilename = getDocumentsDirectory().appendingPathComponent(relativePath)
        self.currentRecordingURL = relativePath
//        print(audioFilename)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 22050.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitRateKey: 32000
        ] as [String : Any]

// requests permission to record audio & sets up the recorder if permission is granted
        let permissionGranted = await AVAudioApplication.requestRecordPermission()
        guard permissionGranted else {
            logger.error("Recording permission denied")
            throw AudioRecorderError.recordingPermissionDenied
        }

        do {
            try await setupAudioSession()
//                    print("audio setup successful")
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder?.delegate = self //allows responses to certain events from the audioRecorder, such as when recording starts, stops, or if an error occurs during recording.
            self.audioRecorder?.record()
            
            return newEntryId
            
        } catch {
            logger.error("Audio setup failed with error: \(error.localizedDescription)")
            throw AudioRecorderError.setupFailed
        }
            
    }


    func stopRecording(completion: @escaping (Result<Data, Error>) -> Void) {
        guard let audioRecorder = audioRecorder else {
            completion(.failure(NSError(domain: "AudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "No active recording"])))
            return
        }

        recordingCompletion = { result in
                switch result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        audioRecorder.stop() 
    }
    

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard flag else {
            recordingCompletion?(.failure(AudioRecorderError.recordingFailed))
               recordingCompletion = nil
               return
           }

        do {
            //tries to create a Data object from the audio file saved at the recorder's URL.
            let audioData = try Data(contentsOf: recorder.url)
//            print("Audio data size: \(audioData.count) bytes")
//            print(recorder.url)
            recordingCompletion?(.success(audioData))
            
        } catch {
            recordingCompletion?(.failure(error))
        }
        
        recordingCompletion = nil
    }
}
