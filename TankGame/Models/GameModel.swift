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

typealias Entities = (
    battlegroundBase: Entity,
    environmentRoot: Entity,
    playfield: Entity,
    playfieldGround: Entity,
    explosionEmitterEntity: Entity
)

/// Maintains game state & in-flight game entities
@Observable class GameModel {
    static let shared = GameModel()
    
    init() {
        Task {
            self.missileTemplate = try? await Entity(named: "Missile/Missile", in: realityKitContentBundle)
            self.tankTemplate = try? await Entity(named: "Tank/Tank", in: realityKitContentBundle)
        }
    }
    
    // Level
    
    var level: Level?
    var collisionSubscriptions: [EventSubscription] = []
    
    func loadLevel(_ level: Level) {
        self.level = level
        
        // Build player
        playerTank = buildTank(level.playerStart)
        
        // Build enemies
        enemyTanks = []
        for enemyTankPosition in level.enemyStarts {
            guard let enemy = buildTank(enemyTankPosition) else { continue }
            enemyTanks.append(enemy)
        }
    }
    
    private func buildTank(_ position: SIMD3<Float>) -> Tank? {
        guard let tankTemplate, let missileTemplate else {
            print("Failed to build tank, entity templates not yet available")
            return nil
        }
        
        let tankEntity = tankTemplate.clone(recursive: true).children[0]
        tankEntity.position = position
        return Tank(tankEntity, missileTemplate)
    }
    
    func initCollisionSubs(_ content: RealityViewContent) {
        // Player collisions
        if let playerTank {
            let playerTankSub = content.subscribe(to: CollisionEvents.Began.self, on: playerTank.root) { event in
                print("Collision Detected, Player Tank Hit! (A: \(event.entityA.name) -> B: \(event.entityB.name))")
            }
            collisionSubscriptions.append(playerTankSub)
        }
        
        // Enemy collisions
        for enemyTank in enemyTanks {
            let enemyTankSub = content.subscribe(to: CollisionEvents.Began.self, on: enemyTank.root) { event in
                print("Collision Detected, Enemy Tank Hit! (A: \(event.entityA.name) -> B: \(event.entityB.name))")
                
                // Handle missile collision
                guard let missile = event.entityB.components[TankMissileComponent.self] else { return }
                self.handleMissileHit(missile, enemyTank)
            }
            collisionSubscriptions.append(enemyTankSub)
        }
    }
    
    // Battleground
    
    var battlegroundBase = Entity()
    var playfield = Entity()
    
    func initBattlegroundEntities(_ entities: Entities) {
        // Save received entities
        let (battlegroundBase, environmentRoot, playfield, _, explosionEmitterEntity) = entities
        
        self.environmentRoot = environmentRoot
        self.explosionEmitter = explosionEmitterEntity.components[ParticleEmitterComponent.self]
        self.playfield = playfield
        self.battlegroundBase = battlegroundBase
        
        // Add tanks to playfield
        if let playerTank {
            self.playfield.addChild(playerTank.root)
            for enemyTank in enemyTanks {
                self.playfield.addChild(enemyTank.root)
            }
        }
    }
    
    // Tanks
    
    var tankTemplate: Entity?
    var playerTank: Tank?
    var enemyTanks: [Tank] = []
    
    // Commands
    
    var selectedCommand: TankCommandType = .move
    var tankCommands: [TankCommand] = [] {
        didSet {
            // Issue command to tank on add
            guard let nextCommand = tankCommands.last else { return }
            if let newMissile = playerTank?.handleNextCommand(nextCommand) {
                addMissileEntity(newMissile)
            }
        }
    }
    
    // Move Target
    
    var moveTargetEntity: Entity?
    
    func setMoveTargetEntity(_ entity: Entity) {
        moveTargetEntity?.removeFromParent()
        moveTargetEntity = entity
    }
    
    // Missile Targets
    
    var missileTargetEntities: [TankCommand.ID: Entity] = [:]
    
    func addMissileTargetEntity(_ id: TankCommand.ID, _ entity: Entity) {
        missileTargetEntities[id] = entity
    }
    
    func removeMissileTargetEntity(_ id: TankCommand.ID) -> Entity? {
        guard let missileTargetEntity = missileTargetEntities.removeValue(forKey: id) else { return nil }
        missileTargetEntity.removeFromParent()
        return missileTargetEntity
    }
    
    // Missiles
    
    let maxMissiles = 3
    var missileTemplate: Entity?
    var explosionEmitter: ParticleEmitterComponent?
    var missileEntities: [UUID: Entity] = [:]
    
    func addMissileEntity(_ missileEntity: Entity) {
        guard let missile = missileEntity.components[TankMissileComponent.self] else { return }
        missileEntities[missile.id] = missileEntity
    }
    
    func removeMissileEntity(_ id: UUID) -> Entity? {
        guard let missileEntity = missileEntities.removeValue(forKey: id) else { return nil }
        missileEntity.components.remove(TankMissileComponent.self)
        missileEntity.removeFromParent()
        return missileEntity
    }
    
    // Podium
    
    var podiumBehavior: PodiumBehavior = .floatMid
    var environmentRoot: Entity?
}

// MARK: - GameModel + Tank Commands
extension GameModel {
    
    /// Capture target position values from gesture and issue command
    func targetTappedPosition(_ tapEvent: EntityTargetValue<DragGesture.Value>) {
        // Skip if shooting and all missiles are already in play
        if selectedCommand == .shoot,
           missileTargetEntities.count >= maxMissiles {
            return
        }
        
        // Issue command and visualize target
        let target = Target(tapEvent, playerTank)
        let command = TankCommand(commandType: selectedCommand, target: target)
        tankCommands.append(command)
        addTargetEntity(target, command.id)
    }
    
    /// Build and add target entity to visualize where the tank/missile is aiming
    private func addTargetEntity(_ target: Target, _ id: TankCommand.ID) {
        // Build target entity
        let targetEntityColor: UIColor = selectedCommand == .move ? .white : .red
        let targetEntity = ModelEntity(
            mesh: .generateSphere(radius: 0.1),
            materials: [UnlitMaterial(color: targetEntityColor)]
        )
        targetEntity.setPosition(target.posPlayfield, relativeTo: nil)
        
        // Add to scene
        switch selectedCommand {
        case .move:  setMoveTargetEntity(targetEntity)
        case .shoot: addMissileTargetEntity(id, targetEntity)
        }
        playfield.addChild(targetEntity)
    }
    
    /// Damage tank (if present), remove missile & target entity, then create explosion
    func handleMissileHit(_ missile: TankMissileComponent, _ hitTank: Tank? = nil) {
        // Damage tank
        if let hitTank {
            hitTank.damage()
            if !hitTank.health.isAlive {
                let tankPosition = hitTank.root.convert(position: .zero, to: playfield)
                addExplosion(tankPosition, scale: 3)
                
                hitTank.root.removeFromParent()
            }
        }
        
        // Explode missile
        let hitPosition = missileEntities[missile.id]?.convert(position: .zero, to: playfield)
        
        let _ = removeMissileEntity(missile.id)
        let _ = removeMissileTargetEntity(missile.commandId)
        
        if let explosionPosition = hitPosition {
            addExplosion(explosionPosition)
        }
    }
    
    private func addExplosion(_ position: SIMD3<Float>, scale: Float = 1.0) {
        // add explosion emitter
        guard var explosionEmitterComponent = explosionEmitter else { return }
        explosionEmitterComponent.restart()
        let explosionEntity = Entity()
        explosionEntity.position = position
        explosionEntity.scale = .init(repeating: scale)
        explosionEntity.components[ParticleEmitterComponent.self] = explosionEmitterComponent
        explosionEntity.components[ExplosionComponent.self] = ExplosionComponent()
        playfield.addChild(explosionEntity)
        
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
        case .floatLow: newTransform.translation = SIMD3<Float>(x: 0, y: 0, z: -10)
        case .floatMid: newTransform.translation = SIMD3<Float>(x: 0, y: -3, z: -10)
        case .floatHigh: newTransform.translation = SIMD3<Float>(x: 0, y: -6, z: -10)
        default: break
        }
        return newTransform
    }
}
