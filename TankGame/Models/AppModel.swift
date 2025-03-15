//
//  AppModel.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI
import Observation
import RealityKit

struct Missile {
    let missileEntity: Entity
    let targetEntity: Entity
}

/// Maintains app-wide state
@Observable
class AppModel {
    static let shared = AppModel()
    
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
            description: "**Welcome to Tank Game**\n\nThis is the tutorial level.\n\nPerform the following 2 actions to complete the tutorial: \n- Move the tank forward\n- shoot the enemy tank"
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
    var moveTargetEntity: Entity?
    let maxMissiles = 5
    var shootTargetEntities: [TankCommand.ID: Entity] = [:]
    
    var selectedCommand: TankCommandType = .move
    var tankCommands: [TankCommand] = []
    
    func commandTank(target: Target) -> Entity? {
        // Skip if shooting and all missiles already in play
        if selectedCommand == .shoot,
           shootTargetEntities.count >= maxMissiles {
            return nil
        }
        
        // Issue command
        let command = TankCommand(commandType: selectedCommand, target: target)
        tankCommands.append(command)
        
        // Add target entity
        let targetEntity = buildTargetEntity(target, command.id)
        switch selectedCommand {
        case .move:
            moveTargetEntity?.removeFromParent()
            moveTargetEntity = targetEntity
        case .shoot:
            shootTargetEntities[command.id] = targetEntity
        }
        
        return targetEntity
    }
    
    private func buildTargetEntity(_ target: Target, _ id: TankCommand.ID) -> Entity {
        let targetEntityColor: UIColor = selectedCommand == .move ? .white : .red
        let targetEntity = ModelEntity(
            mesh: .generateSphere(radius: 0.1),
            materials: [UnlitMaterial(color: targetEntityColor)]
        )
        targetEntity.setPosition(target.posBattleground, relativeTo: nil)
        return targetEntity
    }
    
    func handleMissleHit(_ commandId: TankCommand.ID) {
        if let shootTargetEntity = shootTargetEntities.removeValue(forKey: commandId) {
            // add explosion emitter
            
            
            // remove target
            shootTargetEntity.removeFromParent()
        }
    }
    
    // Podium
    var podiumBehavior: PodiumBehavior = .floatMid
    func updatePodiumBehavior(_ newBehavior: PodiumBehavior) {
        guard let environmentRoot else { return }
        let newTransform = buildNewEnvironmentTransform(environmentRoot, newBehavior)
        environmentRoot.move(to: newTransform, relativeTo: environmentRoot.parent, duration: 1)
    }
    
    private func buildNewEnvironmentTransform(_ environmentRoot: Entity, _ newPodiumBehavior: PodiumBehavior) -> Transform {
        var newTransform = environmentRoot.transform
        switch newPodiumBehavior {
        case .floatLow: newTransform.translation = lowTransform
        case .floatMid: newTransform.translation = midTransform
        case .floatHigh: newTransform.translation = highTransform
        default: break
        }
        return newTransform
    }
    
    var environmentRoot: Entity?
    let lowTransform: SIMD3<Float> = SIMD3<Float>(x: 0, y: 0, z: -8)
    let midTransform: SIMD3<Float> = SIMD3<Float>(x: 0, y: -2.5, z: -8)
    let highTransform: SIMD3<Float> = SIMD3<Float>(x: 0, y: -5, z: -8)
}
