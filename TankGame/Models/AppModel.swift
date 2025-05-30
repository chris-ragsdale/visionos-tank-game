//
//  AppModel.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI
import Observation
import RealityKit

/// Maintains app-wide state
@Observable class AppModel {
    // Scene IDs
    let mainWindowID = "MainWindow"
    let immersiveSpaceID = "ImmersiveSpace"
    let tankControlsPanelID = "TankControlsPanel"
    
    // Navigation
    var selectedLevel: Level.ID?
    var navPath: [Level.ID] = []
    
    func setSelectedLevel(_ id: Level.ID?) {
        selectedLevel = id
        navPath = id == nil ? [] : [id!]
    }
    
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
            name: "Tutorial",
            description: """
            **Welcome to Tank Game**
            
            This is the tutorial level.
            
            Perform the following 2 actions to complete the tutorial: 
            - Move the tank forward
            - shoot the enemy tank
            """,
            player: .init(x: 0, y: 0.145, z: 4),
            enemies: [
                (UUID(), .init(x: 0, y: 0.145, z: -4))
            ],
            winConditions: [ .enemiesKilled ]
        ),
        Level(
            id: 1,
            name: "Level 1",
            description: "Welcome to level 1",
            player: .init(x: 0, y: 0.145, z: 4),
            enemies: [
                (UUID(), .init(x: 0, y: 0.145, z: -4))
            ],
            winConditions: [ .enemiesKilled ]
        ),
        Level(
            id: 2,
            name: "Level 2",
            description: "Welcome to level 2",
            player: .init(x: 0, y: 0.145, z: 4),
            enemies: [
                (UUID(), .init(x: 3, y: 0.145, z: -4)),
                (UUID(), .init(x: -3, y: 0.145, z: -4))
            ],
            winConditions: [ .enemiesKilled ]
        ),
        Level(
            id: 3,
            name: "Level 3",
            description: "Welcome to level 3",
            player: .init(x: 0, y: 0.145, z: 4),
            enemies: [
                (UUID(), .init(x: 0, y: 0.145, z: -4)),
                (UUID(), .init(x: 3, y: 0.145, z: -4)),
                (UUID(), .init(x: -3, y: 0.145, z: -4))
            ],
            winConditions: [ .enemiesKilled ]
        ),
        Level(
            id: 4,
            name: "Level 4",
            description: "Welcome to level 4",
            player: .init(x: 0, y: 0.145, z: 4),
            enemies: [
                (UUID(), .init(x: 0, y: 0.145, z: -4)),
                (UUID(), .init(x: 3, y: 0.145, z: -4)),
                (UUID(), .init(x: -3, y: 0.145, z: -4))
            ],
            winConditions: [ .enemiesKilled ]
        ),
        Level(
            id: 5,
            name: "Level 5",
            description: "Welcome to level 5",
            player: .init(x: 0, y: 0.145, z: 4),
            enemies: [
                (UUID(), .init(x: 0, y: 0.145, z: -4)),
                (UUID(), .init(x: 3, y: 0.145, z: -4)),
                (UUID(), .init(x: -3, y: 0.145, z: -4))
            ],
            winConditions: [ .enemiesKilled ]
        )
    ]
    
    func startLevel(_ id: Level.ID) {
        guard let levelIdx = levels.firstIndex(where: { $0.id == id })
        else { return }
        
        let completionState = levels[levelIdx].completionState
        switch completionState {
        case .inProgress, .completed:
            return
        case .notStarted:
            levels[levelIdx].completionState = .inProgress
        }
    }
}
