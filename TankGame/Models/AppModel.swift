//
//  AppModel.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI
import Observation

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
    let id: Int
    let name: String
    let completionState: CompletionState = .notStarted
}

/// Maintains app-wide state
@MainActor @Observable
class AppModel {
    
    // Scene IDs
    let mainWindowID = "MainWindow"
    let immersiveSpaceID = "ImmersiveSpace"
    let tankControlsPanelID = "TankControlsPanel"
    
    // Open/Close State
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    var tankControlsOpen = false
    
    // Levels
    var levels: [Level] = [
        Level(
            id: 0,
            name: "Tutorial"
        ),
        Level(
            id: 1,
            name: "Level 1"
        ),
        Level(
            id: 2,
            name: "Level 2"
        ),
        Level(
            id: 3,
            name: "Level 3"
        ),
        Level(
            id: 4,
            name: "Level 4"
        ),
        Level(
            id: 5,
            name: "Level 5"
        )
    ]
    
}
