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
@MainActor @Observable
class AppModel {
    
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
            description: "Welcome to Tank Game. This is the tutorial level. Perform the following 2 actions to complete the tutorial: Move the tank forward, shoot the enemy tank"
        ),
        Level(
            id: 1,
            name: "Level 1",
            description: "Welcome to level 1"
        ),
        Level(
            id: 2,
            name: "Level 2",
            description: "Welcome to level 2"
        ),
        Level(
            id: 3,
            name: "Level 3",
            description: "Welcome to level 3"
        ),
        Level(
            id: 4,
            name: "Level 4",
            description: "Welcome to level 4"
        ),
        Level(
            id: 5,
            name: "Level 5",
            description: "Welcome to level 5"
        )
    ]
    
    // Tank
    var tankEntity = Entity()
    var tankCommands: [TankCommand] = []
    
    // Podium
    var podiumBehavior: PodiumBehavior = .floatMid
    func updatePodiumBehavior(_ newBehavior: PodiumBehavior) {
        guard let environmentRoot else { return }
        let newTransform = buildNewEnvironmentTransform(environmentRoot, newBehavior)
        environmentRoot.move(to: newTransform, relativeTo: environmentRoot.parent, duration: 1)
    }
    
    private func buildNewEnvironmentTransform(_ environmentRoot: Entity, _ newBehavior: PodiumBehavior) -> Transform {
        var newTransform = environmentRoot.transform
        switch newBehavior {
        case .floatLow:
            newTransform.translation = lowTransform
        case .floatMid:
            newTransform.translation = midTransform
        case .floatHigh:
            newTransform.translation = highTransform
        default: break
        }
        return newTransform
    }
    
    var environmentRoot: Entity?
    let lowTransform: SIMD3<Float> = SIMD3<Float>(x: 0, y: -0.5, z: -8)
    let midTransform: SIMD3<Float> = SIMD3<Float>(x: 0, y: -2, z: -8)
    let highTransform: SIMD3<Float> = SIMD3<Float>(x: 0, y: -4, z: -8)
}
