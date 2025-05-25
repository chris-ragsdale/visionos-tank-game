//
//  Level.swift
//  TankGame
//
//  Created by Emily Elson on 3/9/25.
//

import SwiftUI

struct Level: Identifiable, Equatable {
    typealias ID = Int
    
    let id: ID
    let name: String
    let description: LocalizedStringKey
    let playerStart: SIMD3<Float>
    let enemyStarts: [SIMD3<Float>]
    var winConditions: [WinCondition]
    var completionState: CompletionState = .notStarted
}

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

enum WinCondition: Equatable {
    case enemyKilled(Int, Bool)
    case tankMoved(Bool)
}
