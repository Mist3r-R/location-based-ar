//
//  LBARView+worldMap.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 21.05.2021.
//

import Foundation
import ARKit


public extension LBARView {
    
    func getWorldMapData(_ completion: @escaping (Result<ARWorldMap, WorldMapError>) -> Void) {
        
        guard self.trackingStatus.state == .tracking else {
            completion(.failure(.locationUnavailable))
            return
        }
        
        self.session.getCurrentWorldMap { map, error in
            if let error = error {
                print("\(#file) -- error while loading world map -- \(error)")
                completion(.failure(.arError))
                return
            }
            guard let map = map else {
                completion(.failure(.emptyData))
                return
            }
            completion(.success(map))
        }
    }
    
    func getCompressedWorldMapData(_ completion: @escaping (Result<Data, WorldMapError>) -> Void) {
        
        self.getWorldMapData { result in
            switch result {
            case .failure(let err): completion(.failure(err))
            case .success(let map):
                self.compress(map, completion: completion)
            }
        }
    }
    
    func getCurrentWorldMapWithLocationData(
        _ completion: @escaping (Result<WorldMap, WorldMapError>) -> Void) {
        
        guard let lastLocation = self.lastSceneLocation,
              let lastAccuracy = self.lastSceneLocationAccuracy else {
            completion(.failure(.locationUnavailable))
            return
        }
        
        self.getWorldMapData { result in
            switch result {
            case .failure(let err): completion(.failure(err))
            case .success(let map):
                let worldMapData = WorldMap(
                    coordinate: lastLocation.coordinate,
                    accuracy: lastAccuracy,
                    arWorldMap: map
                )
                completion(.success(worldMapData))
            }
        }
    }
    
    // save world map to path
    
    // load world map by local url path
    func loadWorldMapData(by url: URL, archived: Bool = false) {
        if archived {
            self.loadArchivedWorldMap(from: url) { result in
                switch result {
                case .failure(let err): break
                case .success(let data):
                    self.decompress(data) { decompressionResult in
                        
                        switch decompressionResult {
                        case .failure(let err): break
                        case .success(let map):
                            DispatchQueue.main.async { self.setWorld(map) }
                        }
                    }
                }
            }
        }
    }
    
    // load world map by codable struct
    func loadWorldMapData(_ worldMap: WorldMap) {
        guard let lastLocation = self.lastSceneLocation,
              let lastAccuracy = self.lastSceneLocationAccuracy else { return }
        
        let distance = lastLocation.distance(from: worldMap.location)
        guard (distance <= lastAccuracy) || (distance <= worldMap.accuracy) else { return }
        guard let map = worldMap.arWorldMap else { return }
        DispatchQueue.main.async { self.setWorld(map) }
    }
    
    // create path for current map
    
    private func compress(_ map: ARWorldMap, completion: @escaping (Result<Data, WorldMapError>) -> Void) {
        DispatchQueue.global().async {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                let compressedData = data.compressed()
                completion(.success(compressedData))
            } catch {
                completion(.failure(.compressionError))
            }
        }
    }
    
    private func decompress(_ mapData: Data, completion: @escaping (Result<ARWorldMap, WorldMapError>) -> Void) {
        do {
            let uncompressedData = try mapData.decompressed()
            guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: uncompressedData) else {
                completion(.failure(.emptyData))
                return
            }
            completion(.success(worldMap))
        } catch {
            completion(.failure(.decompressionError))
        }
    }
    
    private func loadArchivedWorldMap(from url: URL, completion: @escaping (Result<Data, WorldMapError>) -> Void) {
        DispatchQueue.global().async {
            do {
                _ = url.startAccessingSecurityScopedResource()
                defer { url.stopAccessingSecurityScopedResource() }
                let data = try Data(contentsOf: url)
                completion(.success(data))
                
            } catch {
                print("\(#file) -- error when fetchin archive -- \(error.localizedDescription)")
                completion(.failure(.archiveLoadingError))
            }
        }
    }
    
    private func setWorld(_ map: ARWorldMap) {
        if let configuration = self.session.configuration as? ARWorldTrackingConfiguration {
            configuration.initialWorldMap = map
            self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        } else {
            let configuration = LBARView.defaultConfiguration()
            configuration.initialWorldMap = map
            self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }
}
