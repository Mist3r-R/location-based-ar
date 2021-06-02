//
//  URLSession+downloadFile.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 21.05.2021.
//

import Foundation


public extension URLSession {
    
    enum DownloadError: Error {
        case cannotDeleteFile
        case cannotMoveFile
        case failedDownload
    }
    
    /// Downloads a remote file to local storage
    ///
    /// If the object is already stored localy  and `override` param is set to `true`, object will be removed and downloaded again,
    /// otherwise it will be returned as it is
    static func downloadFile(from url: URL, override: Bool = false, completion: @escaping ((Result<URL, Error>) -> Void)) {
        
        let fileManager = FileManager.default
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Url of object in local storage
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        // Check if object is already stored
        if fileManager.fileExists(atPath: destinationUrl.path) {
            // try to delete if override set to true
            if override {
                do { try fileManager.removeItem(atPath: destinationUrl.path) }
                catch let err {
                    print("\(#file) -- error while removing file: \(err.localizedDescription)")
                    completion(.failure(DownloadError.cannotDeleteFile))
                    return
                }
            } else {
                // just return the path otherwise
                completion(.success(destinationUrl))
                return
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let downloadTask = URLSession.shared.downloadTask(with: request) { location, _, error in
            
            if let err = error {
                completion(.failure(err))
                return
            }
            
            guard let location = location else {
                completion(.failure(DownloadError.failedDownload))
                return
            }
            
            do { try fileManager.moveItem(atPath: location.path, toPath: destinationUrl.path) }
            catch let err {
                print("\(#file) -- error while moving file: \(err.localizedDescription)")
                completion(.failure(err))
                return
            }
            
            completion(.success(destinationUrl))
        }
        
        downloadTask.resume()
    }
}
