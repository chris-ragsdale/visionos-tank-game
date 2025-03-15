//
//  GameModel.swift
//  TankGame
//
//  Created by Emily Elson on 3/15/25.
//

import SwiftUI
import Observation
import RealityKit
import RealityKitContent

/// Maintains game state & in-flight game entities
@Observable class GameModel {
    static let shared = GameModel()
    
    // Battleground
    var battlegroundBase = Entity()
    
    // Tank & Commands
    var tank: Tank?
    
    var selectedCommand: TankCommandType = .move
    var tankCommands: [TankCommand] = [] {
        didSet {
            // Issue command to tank on add
            guard let nextCommand = tankCommands.last else { return }
            tank?.handleNextCommand(nextCommand)
        }
    }
    
    var moveTargetEntity: Entity?
    let maxMissiles = 5
    var shootTargetEntities: [TankCommand.ID: Entity] = [:]
    var explosionEmitter: ParticleEmitterComponent?
    
    // Podium
    var podiumBehavior: PodiumBehavior = .floatMid
    var environmentRoot: Entity?
}

// MARK: - +TankCommands
extension GameModel {
    
    /// Capture target position values from gesture and issue command
    func targetTappedPosition(_ tapEvent: EntityTargetValue<SpatialTapGesture.Value>) {
        // Skip if shooting and all missiles are already in play
        if selectedCommand == .shoot,
           shootTargetEntities.count >= maxMissiles {
            return
        }
        
        // Issue command and visualize target
        let target = buildTarget(from: tapEvent)
        let command = TankCommand(commandType: selectedCommand, target: target)
        tankCommands.append(command)
        addTargetEntity(target, command.id)
    }
    
    /// Calculate target from tap gesture
    private func buildTarget(from tapEvent: EntityTargetValue<SpatialTapGesture.Value>) -> Target {
        return Target(
            posBattleground: tapEvent.convert(tapEvent.location3D, from: .local, to: .scene),
            posPlayfield: tapEvent.convert(tapEvent.location3D, from: .local, to: tank!.root.parent!),
            posCannonParent: tapEvent.convert(tapEvent.location3D, from: .local, to: tank!.cannon.parent!)
        )
    }
    
    /// Build and add target entity to visualize where the tank/missile is aiming
    private func addTargetEntity(_ target: Target, _ id: TankCommand.ID) {
        // Build target entity
        let targetEntityColor: UIColor = selectedCommand == .move ? .white : .red
        let targetEntity = ModelEntity(
            mesh: .generateSphere(radius: 0.1),
            materials: [UnlitMaterial(color: targetEntityColor)]
        )
        targetEntity.setPosition(target.posBattleground, relativeTo: nil)
        
        // Add to scene
        switch selectedCommand {
        case .move:
            moveTargetEntity?.removeFromParent()
            moveTargetEntity = targetEntity
        case .shoot:
            shootTargetEntities[id] = targetEntity
        }
        battlegroundBase.addChild(targetEntity)
    }
    
    /// Remove missile target entity and create explosion
    func handleMissleHit(_ commandId: TankCommand.ID) {
        // remove target
        guard let shootTargetEntity = shootTargetEntities.removeValue(forKey: commandId) else { return }
        shootTargetEntity.removeFromParent()
        
        // add explosion emitter
        guard var explosionEmitterComponent = explosionEmitter else { return }
        explosionEmitterComponent.restart()
        let explosionEntity = Entity()
        explosionEntity.position = shootTargetEntity.position
        explosionEntity.components[ParticleEmitterComponent.self] = explosionEmitterComponent
        explosionEntity.components[ExplosionComponent.self] = ExplosionComponent()
        battlegroundBase.addChild(explosionEntity)
        
        // remove explosion in 2s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            explosionEntity.removeFromParent()
        }
    }
}

// MARK: - +Podium
extension GameModel {
    
    /// Move world relative to podium
    func updatePodiumBehavior(_ newBehavior: PodiumBehavior) {
        guard let environmentRoot else { return }
        let newTransform = buildNewEnvironmentTransform(environmentRoot, newBehavior)
        environmentRoot.move(to: newTransform, relativeTo: environmentRoot.parent, duration: 1)
    }
    
    /// Calculate where environment should be moved to achieve desired "podium behavior" movement effect
    private func buildNewEnvironmentTransform(_ environmentRoot: Entity, _ newPodiumBehavior: PodiumBehavior) -> Transform {
        var newTransform = environmentRoot.transform
        switch newPodiumBehavior {
        case .floatLow: newTransform.translation = SIMD3<Float>(x: 0, y: 0, z: -8)
        case .floatMid: newTransform.translation = SIMD3<Float>(x: 0, y: -2.5, z: -8)
        case .floatHigh: newTransform.translation = SIMD3<Float>(x: 0, y: -5, z: -8)
        default: break
        }
        return newTransform
    }
}
