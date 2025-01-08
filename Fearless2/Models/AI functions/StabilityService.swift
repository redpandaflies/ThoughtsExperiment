//
//  StabilityService.swift
//  TrueBlob
//
//  Created by Yue Deng-Wu on 7/26/24.
//
import AIProxy
import OSLog
import Foundation


final class StabilityService: ObservableObject {
    
    static let instance = StabilityService()
    private init() {}
    
    let loggerStability = Logger.stabilityEvents
    
    let service = AIProxy.stabilityAIService(
                partialKey: "\(Constants.stabilityPartialKey)",
                serviceURL: "https://api.aiproxy.pro/bf7d055e/3e1cc8f6")
    
    private var fileManager = LocalFileManager.instance
    private let folderName = "topic_images"

   
    func getTopicImage(fromPrompt prompt: String, topicId: String) async -> URL? {
        
        let body = StabilityAIStableDiffusionRequestBody(prompt: prompt, negativePrompt: "blurry, bad, deformed, margin, border, frame, person, man, woman, ugly, cluttered, brand, logo, panel, split, app, dashboard, text, distorted, gun, tiling, poorly drawn hands, poorly drawn feet, poorly drawn face, out of frame, extra limbs, disfigured, body out of frame, bad anatomy, watermark, signature, cut off, low contrast, underexposed, overexposed, bad art, beginner, amateur, draft, grainy, error, writing, poster, words", outputFormat: .png)
            
        do {
            loggerStability.log("Getting topic image from Stability")
            
            let response = try await service.stableDiffusionRequest(body: body)
            
            loggerStability.log("Response from Stability: \(String(describing: response))")
            
            if let savedImageURL = self.fileManager.saveImage(imageData: response.imageData, imageId: topicId, folderName: self.folderName) {
                self.loggerStability.info("Image saved to \(savedImageURL)")
                return savedImageURL
            } else {
                self.loggerStability.error("Error saving file")
                return nil
            }
    
        } catch AIProxyError.unsuccessfulRequest(let statusCode, let responseBody) {
            loggerStability.error("Received non-200 status code: \(statusCode) with response body: \(responseBody)")
            return nil
        } catch {
            loggerStability.error("\(error.localizedDescription)")
            return nil
        }
    }
   
    
}

