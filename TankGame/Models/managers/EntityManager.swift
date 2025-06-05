//
//  EntityManager.swift
//  TankGame
//
//  Created by Chris Ragsdale on 6/4/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

typealias TankMaterials = (
    bodyPaintEnemy: ShaderGraphMaterial,
    cannonPaintEnemy: ShaderGraphMaterial,
    roadwheelPaintEnemy: ShaderGraphMaterial
)

@Observable
class EntityManager {
    // Tanks
    var playerTank: Tank?
    var enemyTanks: [Tank] = []
    
    // Missiles
    var missileEntities: [TankCommand.ID: Entity] = [:]
    
    // Targets
    var missileTargetEntities: [TankCommand.ID: Entity] = [:]
    var moveTargetEntities: [UUID: Entity] = [:]
    
    // Scene References
    var battlegroundBase = Entity()
    var playfield = Entity()
    var environmentRoot: Entity?
    
    // Templates
    var missileTemplate: Entity?
    var tankTemplate: Entity?
    var tankMaterials: TankMaterials?
    var explosionEmitter: ParticleEmitterComponent?
    
    init() {
        loadAssets()
    }
}

// MARK: - Tanks

extension EntityManager {
    func enemyTank(_ id: UUID) -> Tank? {
        enemyTanks.first { $0.id == id }
    }
    
    func buildTank(_ tankType: TankType, _ position: SIMD3<Float>, _ id: UUID? = nil) -> Tank? {
        guard let tankTemplate, let missileTemplate, let tankMaterials else {
            print("Failed to build tank, entity templates not yet available")
            return nil
        }
        
        let tankEntity = tankTemplate.clone(recursive: true).children[0]
        tankEntity.position = position
        return Tank(id, tankType, tankEntity, missileTemplate, tankMaterials)
    }
}

// MARK: - Missiles

extension EntityManager {
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
}

// MARK: - Targets

extension EntityManager {
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
    
    func addMissileTargetEntity(_ id: TankCommand.ID, _ entity: Entity) {
        missileTargetEntities[id] = entity
    }
    
    func removeMissileTargetEntity(_ id: TankCommand.ID) -> Entity? {
        guard let missileTargetEntity = missileTargetEntities.removeValue(forKey: id) else { return nil }
        missileTargetEntity.removeFromParent()
        return missileTargetEntity
    }
}

// MARK: - Scene References

typealias BattlegroundEntities = (
    battlegroundBase: Entity,
    environmentRoot: Entity,
    playfield: Entity,
    playfieldGround: Entity,
    explosionEmitterEntity: Entity
)

extension EntityManager {
    func setupBattlegroundEntities(_ entities: BattlegroundEntities) {
        // Save received entities
        let (battlegroundBase, environmentRoot, playfield, _, explosionEmitterEntity) = entities
        
        self.environmentRoot = environmentRoot
        self.explosionEmitter = explosionEmitterEntity.components[ParticleEmitterComponent.self]
        self.playfield = playfield
        self.battlegroundBase = battlegroundBase
        
        // Add tanks to playfield
        if let playerTank {
            playfield.addChild(playerTank.root)
        }
        for enemyTank in enemyTanks {
            playfield.addChild(enemyTank.root)
        }
    }
    
    /// Move environment up or down based on new podium selection
    func updatePodiumEnvironmentOffset(_ newBehavior: PodiumBehavior) {
        guard let environmentRoot else { return }
        
        var newTransform = environmentRoot.transform
        switch newBehavior {
        case .floatLow: newTransform.translation = SIMD3<Float>(x: 0, y: 0, z: -10)
        case .floatMid: newTransform.translation = SIMD3<Float>(x: 0, y: -3, z: -10)
        case .floatHigh: newTransform.translation = SIMD3<Float>(x: 0, y: -6, z: -10)
        default: break
        }
        environmentRoot.move(to: newTransform, relativeTo: environmentRoot.parent, duration: 1)
    }
}

// MARK: - Assets

extension EntityManager {
    func loadAssets() {
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
}
