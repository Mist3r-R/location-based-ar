//
//  SessionError.swift
//  ARCLDemo
//
//  Created by Miron Rogovets on 02.06.2021.
//

import Foundation


struct SessionError: Identifiable {
    var id: String {
        "\(timestamp)"
    }
    
    
    let timestamp: Date
    let message: String
    
    init(_ error: Error) {
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        self.message = messages.compactMap({ $0 }).joined(separator: "\n")
        self.timestamp = Date()
    }
}
