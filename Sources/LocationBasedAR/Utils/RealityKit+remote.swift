//
//  ModelEntity+remote.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 21.05.2021.
//

import Foundation
import RealityKit
import Combine


public extension ModelEntity {
    
    static func loadModelAsync(
        from url: URL,
        override: Bool = false,
        completion: @escaping ((Result<LoadRequest<ModelEntity>, Error>) -> Void)
    ) {
        URLSession.downloadFile(from: url, override: override) { result in
            switch result {
            case .failure(let err): completion(.failure(err))
            case .success(let location):
                DispatchQueue.main.async {
                    completion(.success(loadModelAsync(contentsOf: location)))
                }
            }
        }
    }
}


public extension Entity {
    
    static func loadAsync(
        from url: URL,
        override: Bool = false,
        completion: @escaping ((Result<LoadRequest<Entity>, Error>) -> Void)
    ) {
        URLSession.downloadFile(from: url, override: override) { result in
            switch result {
            case .failure(let err): completion(.failure(err))
            case .success(let location):
                DispatchQueue.main.async {
                    completion(.success(loadAsync(contentsOf: location)))
                }
            }
        }
    }
}

public extension TextureResource {
    
    static func loadAsync(
        from url: URL,
        override: Bool = false,
        completion: @escaping ((Result<LoadRequest<TextureResource>, Error>) -> Void)
    ) {
        URLSession.downloadFile(from: url, override: override) { result in
            switch result {
            case .failure(let err): completion(.failure(err))
            case .success(let location):
                DispatchQueue.main.async {
                    completion(.success(loadAsync(contentsOf: location)))
                }
            }
        }
    }
}
