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
import Combine

enum PlayState {
    case ready, playing, paused
    
    var notPlaying: Bool { self != .playing }
}

enum LevelEvent {
    case tankKilled(UUID)
}

struct GameState {
    
}

/// Maintains game state & in-flight game entities
@Observable
class GameModel {
    static let shared = GameModel()
    
    var entityManager = EntityManager()
    var combatManager = CombatManager()
    
    // Play State
    
    var playState: PlayState = .ready
    
    func setPlayState(_ state: PlayState) {
        switch state {
        case .ready:
            toggleSystemsPaused(paused: true)
            playState = .ready
        case .playing:
            toggleSystemsPaused(paused: false)
            playState = .playing
        case .paused:
            toggleSystemsPaused(paused: true)
            playState = .paused
        }
    }
    
    func toggleSystemsPaused(paused: Bool?) {
        AISystem.isPaused = paused ?? !AISystem.isPaused
        ExplosionSystem.isPaused = paused ?? !ExplosionSystem.isPaused
        MovementSystem.isPaused = paused ?? !MovementSystem.isPaused
        ProjectileSystem.isPaused = paused ?? !ProjectileSystem.isPaused
    }
    
    // Level
    
    var level: Level?
    var collisionSubscriptions: [EventSubscription] = []
    
    func loadLevel(_ level: Level) {
        self.level = level
        playState = .ready
        
        entityManager.loadTanks(from: level)
    }
    
    private func handleLevelEvent() {
        
    }
    
    func initCollisionSubs(_ content: RealityViewContent) {
        // Player collisions
        if let playerTank = entityManager.playerTank {
            let playerTankSub = content.subscribe(to: CollisionEvents.Began.self, on: playerTank.root) { event in
                print("Collision Detected, Player Tank Hit! (A: \(event.entityA.name) -> B: \(event.entityB.name))")
                
                // Handle missile collision
                guard let missile = event.entityB.components[ProjectileComponent.self],
                      missile.shooterId != playerTank.id
                else { return }
                
                self.hitTank(playerTank)
                self.explodeMissile(missile)
            }
            collisionSubscriptions.append(playerTankSub)
        }
        
        // Enemy collisions
        for enemyTank in entityManager.enemyTanks.values {
            let enemyTankSub = content.subscribe(to: CollisionEvents.Began.self, on: enemyTank.root) { event in
                print("Collision Detected, Enemy Tank Hit! (A: \(event.entityA.name) -> B: \(event.entityB.name))")
                
                // Handle missile collision
                guard let missile = event.entityB.components[ProjectileComponent.self],
                      missile.shooterId != enemyTank.id
                else { return }
                
                self.hitTank(enemyTank)
                self.explodeMissile(missile)
            }
            collisionSubscriptions.append(enemyTankSub)
        }
    }
    
    // Commands
    
    var selectedCommand: TankCommandType = .move
    var playerTankCommands: [TankCommand] = [] {
        didSet {
            // Issue command to tank on add
            guard let nextCommand = playerTankCommands.last else { return }
            if let newMissile = entityManager.playerTank?.handleCommand(nextCommand) {
                entityManager.addMissileEntity(newMissile)
            }
        }
    }
    var enemyTankCommands: [TankCommand] = [] {
        didSet {
            // Issue command to tank on add
            guard let nextCommand = enemyTankCommands.last else { return }
            
            // Find associated enemy tank
            let enemyTank = entityManager.enemyTank(nextCommand.tankId)
            // Issue command
            if let newMissile = enemyTank?.handleCommand(nextCommand) {
                entityManager.addMissileEntity(newMissile)
            }
        }
    }
    
    // Podium
    
    var podiumBehavior: PodiumBehavior = .floatMid
    
    func handlePodiumBehaviorChange(_ newBehavior: PodiumBehavior) {
        switch newBehavior {
        case .floatLow, .floatMid, .floatHigh:
            entityManager.updatePodiumEnvironmentOffset(newBehavior)
        case .follow:
            // TODO
            return
        }
    }
}

// MARK: - + TankCommands
extension GameModel {
    
    /// Issue selected player command using position values from tap gesture
    func commandPlayer(_ tapEvent: EntityTargetValue<DragGesture.Value>) {
        guard let playerTank = entityManager.playerTank
        else { return }
        
        // Skip if shooting and all missiles are already in play
        if selectedCommand == .shoot && entityManager.playerActiveMissiles >= Tank.maxMissiles {
            return
        }
        
        // Issue command and visualize target
        let target = Target(playerTank, tapEvent)
        let command = TankCommand(tankId: playerTank.id, commandType: selectedCommand, target: target)
        playerTankCommands.append(command)
        entityManager.addTargetEntity(target, command)
    }
    
    /// Issue enemy command using player localtion
    func commandEnemy(_ commandType: TankCommandType, _ enemyTankId: UUID, _ playerTank: Tank) {
        guard let enemyTank = entityManager.enemyTank(enemyTankId)
        else { return }
        
        let target = Target(enemyTank, playerTank)
        let command = TankCommand(tankId: enemyTankId, commandType: commandType, target: target)
        enemyTankCommands.append(command)
        entityManager.addTargetEntity(target, command)
    }
    
    /// Remove missile & target entity, then create explosion
    func explodeMissile(_ missile: ProjectileComponent) {
        let hitPosition = entityManager.missileEntities[missile.id]?.convert(position: .zero, to: entityManager.playfield)
        
        let _ = entityManager.removeMissileEntity(missile.id)
        let _ = entityManager.removeMissileTargetEntity(missile.commandId)
        
        if let explosionPosition = hitPosition {
            addExplosion(explosionPosition)
        }
    }
    
    private func hitTank(_ tank: Tank) {
        tank.damage()
        if !tank.health.isAlive {
            // TODO: create death event
            
            // explode
            let tankPosition = tank.root.convert(position: .zero, to: entityManager.playfield)
            addExplosion(tankPosition, scale: 3)
            
            // clear entities
            let _ = entityManager.removeMoveTargetEntity(tank.id)
            tank.root.removeFromParent()
        }
    }
    
    private func addExplosion(_ position: SIMD3<Float>, scale: Float = 1.0) {
        // add explosion emitter
        guard var explosionEmitterComponent = entityManager.explosionEmitter
        else { return }
        
        explosionEmitterComponent.restart()
        let explosionEntity = Entity()
        explosionEntity.position = position
        explosionEntity.scale = .init(repeating: scale)
        explosionEntity.components[ParticleEmitterComponent.self] = explosionEmitterComponent
        explosionEntity.components[ExplosionComponent.self] = ExplosionComponent()
        entityManager.playfield.addChild(explosionEntity)
        
        // remove explosion in 2s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            explosionEntity.removeFromParent()
        }
    }
}
