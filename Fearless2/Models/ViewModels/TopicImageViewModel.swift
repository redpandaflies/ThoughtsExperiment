//
//  TopicImageViewModel.swift
//  Fearless2
//
//  Created by Yue Deng-Wu on 12/27/24.
//

import CoreData
import Foundation
import OSLog
import SwiftUI

enum TopicImageStatus {
    case loading
    case imageReady
    case imageNotFound
}


final class TopicImageViewModel: ObservableObject {
    
    @Published var imageStatus: TopicImageStatus = .loading
    @Published var topicImage: UIImage? = nil
    @Published var imageTransition: Bool = false
  
    private var fileManager = LocalFileManager.instance
    private let imageCacheManager = ImageCacheManager.instance
    private var topicViewModel: TopicViewModel
    
    private let folderName = "topic_images"
    private var currentImageId: String?
   
    let loggerCoreData = Logger.coreDataEvents
    let loggerFileManager = Logger.fileManagerEvents
    
    init(topicViewModel: TopicViewModel, topic: Topic) {
        self.topicViewModel = topicViewModel
        Task {
            await loadSavedImage(topic: topic)
        }
    }
    
    func loadSavedImage(topic: Topic) async {
        //get topicId, which will be used as image ID
        let imageId = await MainActor.run {
            return topic.topicId.uuidString
        }
        
//        //MARK: prevent reloading
        if imageId == currentImageId {
            return //No need to process the same URL again
        }
        currentImageId = imageId
        
       //check cache first
        if let cachedImage = imageCacheManager.getImage(key: imageId) {
            await MainActor.run {
                self.imageStatus = .imageReady
                self.topicImage = cachedImage
            }
            return
        }
        
        //get image from file manager, if needed
        if let savedImage = fileManager.getImage(imageId: imageId, folderName: folderName) {
           await MainActor.run {
               self.imageStatus = .imageReady
               self.topicImage = savedImage
               self.imageTransition = true
           }
            imageCacheManager.saveImage(key: imageId, value: savedImage)
            
        } else {
            loggerFileManager.info("Couldn't find image in file manager with ID: \(imageId). Updating image status.")
            await MainActor.run {
                if topicViewModel.generatingImage {
                    self.imageStatus = .loading
                } else {
                    self.imageStatus = .imageNotFound
                }
                self.currentImageId = ""
            }
        }
    }
    
}
