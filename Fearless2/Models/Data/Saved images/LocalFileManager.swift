//
//  LocalFileManager.swift
//  TrueBlob
//
//  Created by Yue Deng-Wu on 1/2/24.
//

import Foundation
import OSLog
import SwiftUI

final class LocalFileManager {
    
    static let instance = LocalFileManager()
    private init() {}
    
    let loggerFileManager = Logger.fileManagerEvents
    
    func saveImage(imageData: Data, imageId: String, folderName: String) -> URL? {
        
        //create folder
        createFolderIfNeeded(folderName: folderName)
        
        //get path for image
        guard
            let url = getURLForImage(imageId: imageId, folderName: folderName)
            else {return nil}
        
        //save image to path
        do {
            try imageData.write(to: url)
            return url
        } catch let error {
            loggerFileManager.error("Error saving image. Image ID: \(imageId). \(error.localizedDescription)")
            return nil
        }
    }
    
    private func createFolderIfNeeded(folderName: String) {
        guard let url = getURLForFolder(folderName: folderName) else {return}
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                print("Error creating directory. FolderName: \(folderName). \(error)")
            }
        }
    }
    
    func getImage(imageId: String, folderName: String) -> UIImage? {
        guard
            let url = getURLForImage(imageId: imageId, folderName: folderName),
            FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }
    
   
    
    private func getURLForFolder(folderName: String) -> URL? {
        guard let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(folderName)
    }
    
    private func getURLForImage(imageId: String, folderName: String) -> URL? {
        guard let folderURL = getURLForFolder(folderName: folderName) else {
            return nil
        }
        return folderURL.appendingPathComponent(imageId + ".png")
    }
    
    func deleteImage(imageId: String, folderName: String) {
            guard let url = getURLForImage(imageId: imageId, folderName: folderName),
                  FileManager.default.fileExists(atPath: url.path) else {
                print("Image file not found.")
                return
            }

            do {
                try FileManager.default.removeItem(at: url)
                print("Image deleted successfully.")
            } catch let error {
                print("Error deleting image file: \(error)")
            }
    }

}
