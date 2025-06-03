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

typealias TankMaterials = (
    bodyPaintEnemy: ShaderGraphMaterial,
    cannonPaintEnemy: ShaderGraphMaterial,
    roadwheelPaintEnemy: ShaderGraphMaterial
)

/// Maintains game state & in-flight game entities
@Observable
class GameModel {
    static let shared = GameModel()
    
    init() {
        Task {
            // Load USDA templates
            self.missileTemplate = try? await Entity(
                named: "Missile/Missile",
                in: realityKitContentBundle
            )
            self.tankTemplate = try? await Entity(
                named: "Tank/Tank",
                in: realityKitContentBundle
            )
            
            // Load tank materials
            let bodyPaintEnemy = try? await ShaderGraphMaterial(
                named: "/Root/TankRoot/BodyPaintEnemy",
                from: "Tank/Tank.usda",
                in: realityKitContentBundle
            )
            let cannonPaintEnemy = try? await ShaderGraphMaterial(
                named: "/Root/TankRoot/CannonPaintEnemy",
                from: "Tank/Tank.usda",
                in: realityKitContentBundle
            )
            let roadwheelPaintEnemy = try? await ShaderGraphMaterial(
                named: "/Root/TankRoot/RoadwheelPaintEnemy",
                from: "Tank/Tank.usda",
                in: realityKitContentBundle
            )
            
            guard let bodyPaintEnemy, let cannonPaintEnemy, let roadwheelPaintEnemy
            else { return }
            
            self.tankMaterials = (bodyPaintEnemy, cannonPaintEnemy, roadwheelPaintEnemy)
        }
    }
    
    // Play State
    
    enum PlayState {
        case ready, playing, paused, won
        
        var notPlaying: Bool { self != .playing }
    }
    
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
        case .won:
            toggleSystemsPaused(paused: true)
            playState = .won
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
        
        // Build player
        playerTank = buildTank(.player, level.player)
        
        // Build enemies
        enemyTanks = []
        for (enemyId, enemyPosition) in level.enemies {
            guard let enemy = buildTank(.enemy, enemyPosition, enemyId) else { continue }
            enemyTanks.append(enemy)
        }
    }
    
    private func buildTank(_ tankType: TankType, _ position: SIMD3<Float>, _ id: UUID? = nil) -> Tank? {
        guard let tankTemplate, let missileTemplate, let tankMaterials else {
            print("Failed to build tank, entity templates not yet available")
            return nil
        }
        
        let tankEntity = tankTemplate.clone(recursive: true).children[0]
        tankEntity.position = position
        return Tank(id, tankType, tankEntity, missileTemplate, tankMaterials)
    }
    
    func initCollisionSubs(_ content: RealityViewContent) {
        // Player collisions
        if let playerTank {
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
        for enemyTank in enemyTanks {
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
    var tankMaterials: TankMaterials?
    var tankTemplate: Entity?
    
    var playerTank: Tank?
    var enemyTanks: [Tank] = []
    
    func enemyTank(_ id: UUID) -> Tank? {
        enemyTanks.first { $0.id == id }
    }
    
    // Commands
    
    var selectedCommand: TankCommandType = .move
    var playerTankCommands: [TankCommand] = [] {
        didSet {
            // Issue command to tank on add
            guard let nextCommand = playerTankCommands.last else { return }
            if let newMissile = playerTank?.handleNextCommand(nextCommand) {
                addMissileEntity(newMissile)
            }
        }
    }
    var enemyTankCommands: [TankCommand] = [] {
        didSet {
            // Issue command to tank on add
            guard let nextCommand = enemyTankCommands.last else { return }
            
            // Find associated enemy tank
            let enemyTank = enemyTanks.first(where: { $0.id == nextCommand.tankId })
            // Issue command
            if let newMissile = enemyTank?.handleNextCommand(nextCommand) {
                addMissileEntity(newMissile)
            }
        }
    }
    
    // Move Target
    
    var moveTargetEntities: [UUID: Entity] = [:]
    
    func setMoveTargetEntity(_ tankId: UUID, _ entity: Entity) {
        moveTargetEntities[tankId]?.removeFromParent()
        moveTargetEntities[tankId] = entity
    }
    
    func removeMoveTargetEntity(_ id: UUID) -> Entity? {
        guard let moveTargetEntity = moveTargetEntities.removeValue(forKey: id)
        else { return nil }
        
        moveTargetEntity.removeFromParent()
        return moveTargetEntity
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
    var missileEntities: [TankCommand.ID: Entity] = [:]
    
    func addMissileEntity(_ missileEntity: Entity) {
        guard let missile = missileEntity.components[ProjectileComponent.self] else { return }
        missileEntities[missile.id] = missileEntity
    }
    
    func removeMissileEntity(_ id: UUID) -> Entity? {
        guard let missileEntity = missileEntities.removeValue(forKey: id) else { return nil }
        missileEntity.components.remove(ProjectileComponent.self)
        missileEntity.removeFromParent()
        return missileEntity
    }
    
    var playerActiveMissiles: Int {
        missileEntities.count { (_, missileEntity) in
            // per missile, determine if missile was shot from player
            guard let missile = missileEntity.components[ProjectileComponent.self]
            else { return false }
            
            return missile.shooterId == playerTank?.id
        }
    }
    
    // Podium
    
    var podiumBehavior: PodiumBehavior = .floatMid
    var environmentRoot: Entity?
}

// MARK: - + TankCommands
extension GameModel {
    
    /// Issue selected player command using position values from tap gesture
    func commandPlayer(_ tapEvent: EntityTargetValue<DragGesture.Value>) {
        guard let playerTank else { return }
        
        // Skip if shooting and all missiles are already in play
        if selectedCommand == .shoot && playerActiveMissiles >= 3 {
            return
        }
        
        // Issue command and visualize target
        let target = Target(playerTank, tapEvent)
        let command = TankCommand(tankId: playerTank.id, commandType: selectedCommand, target: target)
        playerTankCommands.append(command)
        addTargetEntity(target, command)//command.id, selectedCommand)
    }
    
    /// Issue enemy command using player localtion
    func commandEnemy(_ commandType: TankCommandType, _ enemyTankId: UUID, _ playerTank: Tank) {
        guard let enemyTank = enemyTanks.first(where: { $0.id == enemyTankId }) else { return }
        
        let target = Target(enemyTank, playerTank)
        let command = TankCommand(tankId: enemyTankId, commandType: commandType, target: target)
        enemyTankCommands.append(command)
        addTargetEntity(target, command)
    }
    
    /// Build and add target entity to visualize where the tank/missile is aiming
    private func addTargetEntity(_ target: Target, _ command: TankCommand) {
        // Build target entity
        let targetEntityColor: UIColor = command.commandType == .move ? .white : .red
        let targetEntity = ModelEntity(
            mesh: .generateSphere(radius: 0.1),
            materials: [UnlitMaterial(color: targetEntityColor)]
        )
        targetEntity.setPosition(target.posPlayfield, relativeTo: nil)
        
        // Add to scene
        switch command.commandType {
        case .move:  setMoveTargetEntity(command.tankId, targetEntity)
        case .shoot: addMissileTargetEntity(command.id, targetEntity)
        }
        playfield.addChild(targetEntity)
    }
    
    /// Remove missile & target entity, then create explosion
    func explodeMissile(_ missile: ProjectileComponent) {
        let hitPosition = missileEntities[missile.id]?.convert(position: .zero, to: playfield)
        
        let _ = removeMissileEntity(missile.id)
        let _ = removeMissileTargetEntity(missile.commandId)
        
        if let explosionPosition = hitPosition {
            addExplosion(explosionPosition)
        }
    }
    
    private func hitTank(_ tank: Tank) {
        tank.damage()
        if !tank.health.isAlive {
            // explode
            let tankPosition = tank.root.convert(position: .zero, to: playfield)
            addExplosion(tankPosition, scale: 3)
            
            let _ = removeMoveTargetEntity(tank.id)
            tank.root.removeFromParent()
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
