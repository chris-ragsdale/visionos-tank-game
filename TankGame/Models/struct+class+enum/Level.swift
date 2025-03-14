//
//  Level.swift
//  TankGame
//
//  Created by Emily Elson on 3/9/25.
//

import SwiftUI

enum CompletionState {
    case notStarted
    case inProgress
    case completed
    
    var icon: some View {
        switch self {
        case .notStarted: Image(systemName: "questionmark.circle").tint(.white)
        case .inProgress: Image(systemName: "ellipsis").tint(.blue)
        case .completed:  Image(systemName: "checkmark.circle").tint(.green)
        }
    }
    
    var isCompleted: Bool {
        switch self {
        case .completed: true
        default: false
        }
    }
}

struct Level: Identifiable, Equatable {
    typealias ID = Int
    
    let id: ID
    let name: String
    let description: LocalizedStringKey
    let completionState: CompletionState = .notStarted
}
