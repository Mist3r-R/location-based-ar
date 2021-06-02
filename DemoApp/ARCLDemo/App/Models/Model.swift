//
//  Model.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 16.05.2021.
//

import SwiftUI
import RealityKit
import Combine


class Model {
    var name: String?
    var url: URL?
    
    var thumbnail: UIImage
    
    var category: ModelCategory
    var modelEntity: ModelEntity?
    
    var description: String {
        switch self.category {
        case .usdzLocal: return "local_\(String(describing: name))"
        case .usdzRemote: return "remote_\(String(describing: url))"
        }
    }
    
    private var cancellable: AnyCancellable?
    
    init(_ category: ModelCategory, name: String? = nil, url: URL? = nil) {
        self.category = category
        self.name = name
        self.url = url
        
        if let name = name {
            self.thumbnail = UIImage(named: name) ?? UIImage(named: "usdzz")!
        } else {
            self.thumbnail = UIImage(named: "usdzz")!
        }
    }
    
    convenience init(url: URL?) {
        self.init(.usdzRemote, url: url)
    }
    
    convenience init(name: String) {
        self.init(.usdzLocal, name: name)
    }
    
    func loadModelEntityAsync() {
        switch self.category {
        case .usdzLocal: self.loadLocalModel()
        case .usdzRemote: self.loadRemoteModel()
        }
    }
    
    private func loadLocalModel() {
        guard let name = name else { return }
        let filename = name + ".usdz"
        cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                switch loadCompletion {
                case .failure(let error): print("Unable to load model entity for \(filename). Error: \(error.localizedDescription)")
                case .finished: break
                }
                
            }, receiveValue: { modelEntity in
                self.modelEntity = modelEntity
                print("DEBUG: -- model entity for \(filename) has been loaded")
            })
    }
    
    private func loadRemoteModel() {
        
        guard let url = url else { return }
        ModelEntity.loadModelAsync(from: url, override: false) { result in
            switch result {
            case .failure(let err): print("Failed to load entity from remode: \(err.localizedDescription)")
            case .success(let loadRequest):
                self.cancellable = loadRequest.sink(receiveCompletion: { loadCompletion in
                    switch loadCompletion {
                    case .failure(let error): print("Unable to load model entity for \(url). Error: \(error.localizedDescription)")
                    case .finished: break
                    }
                    
                }, receiveValue: { modelEntity in
                    self.modelEntity = modelEntity
                    print("DEBUG: -- model entity for \(url) has been loaded")
                })
            }
        }
    }
}


struct Models {
    var all: [Model] = []
    
    init() {
        let robot = Model(name: "toy_robot_vintage")
        let car = Model(name: "toy_car")
        let plane = Model(name: "toy_biplane")
        
        self.all += [robot, car, plane]
        
        if let url = URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/retrotv/tv_retro.usdz") {
            let remote = Model(url: url)
            self.all += [remote]
        }
    }
    
    func get(category: ModelCategory) -> [Model] {
        return all.filter({$0.category == category})
    }
}
