//
//  Tank.swift
//  TankGame
//
//  Created by Emily Elson on 3/15/25.
//

import SwiftUI
import Observation
import RealityKit
import RealityKitContent
import Foundation

struct Health {
    let capacity: Int
    var current: Int
    
    var isAlive: Bool { current > 0 }
}

enum TankType {
    case player, enemy
}

@Observable
class Tank: Identifiable {
    static let maxMissiles = 3
    
    typealias ID = UUID
    let id: ID
    
    let tankType: TankType
    var health = Health(capacity: 5, current: 5)
    
    // Entities
    let root: Entity
    let cannon: Entity
    let cannonShaft: Entity
    let missileTemplate: Entity
    
    init(_ id: UUID? = nil, _ tankType: TankType, _ root: Entity, _ missileTemplate: Entity, _ tankMaterials: TankMaterials) {
        self.id = id ?? UUID()
        self.tankType = tankType
        
        // Configure root
        self.root = root
        Collisions.shared.configureTankCollisions(self.root)
    
        cannon = root.findEntity(named: "Cannon")!
        cannonShaft = cannon.findEntity(named: "Shaft")!
        
        if tankType == .enemy, let id {
            // Add enemy AI
            let enemyAI = AIComponent(tankId: id)
            root.components.set(enemyAI)
            
            // Assign enemy materials
            if let cannonShaft = cannonShaft as? ModelEntity,
               let cannonBase = cannon.findEntity(named: "Base") as? ModelEntity,
               let cannonEnd = cannon.findEntity(named: "End") as? ModelEntity {
                cannonShaft.model?.materials = [tankMaterials.cannonPaintEnemy]
                cannonBase.model?.materials = [tankMaterials.cannonPaintEnemy]
                cannonEnd.model?.materials = [tankMaterials.cannonPaintEnemy]
            }
            if let cannonBody = root.findEntity(named: "Body")?.findEntity(named: "Body") as? ModelEntity {
                cannonBody.model?.materials = [tankMaterials.bodyPaintEnemy]
            }
            if let roadwheelLeft = root.findEntity(named: "WheelsLeft")?.findEntity(named: "Roadwheel") as? ModelEntity,
               let roadwheelRight = root.findEntity(named: "WheelsRight")?.findEntity(named: "Roadwheel") as? ModelEntity {
                roadwheelLeft.model?.materials = [tankMaterials.roadwheelPaintEnemy]
                roadwheelRight.model?.materials = [tankMaterials.roadwheelPaintEnemy]
            }
        }
        
        self.missileTemplate = missileTemplate
    }
}

// MARK: - Tank + Damage

extension Tank {
    func damage() {
        guard health.isAlive else { return }
        
        health.current -= 1
        print("Ouch! New health: \(health.current)/\(health.capacity)")
        
        if !health.isAlive {
            print("Dead!")
        }
    }
}

// MARK: - Tank + Commands

extension Tank {
    func handleCommand(_ command: TankCommand) -> Entity? {
        switch command.commandType {
        case .move:
            move(command)
            return nil
        case .shoot:
            let missile = shoot(command)
            return missile
        }
    }
    
    /// Point tank at target and start moving
    private func move(_ command: TankCommand) {
        // Point tank at target
        root.look(at: command.target.posPlayfield, from: root.position, relativeTo: root.parent)
        
        // Move to target
        root.components[MovementComponent.self] = MovementComponent(
            velocityMps: tankType == .player ? 1.5: 0.5,
            target: command.target
        )
    }
    
    /// Point cannon at target, add missile and start moving missile
    private func shoot(_ command: TankCommand) -> Entity? {
        // Point cannon towards target
        cannon.look(at: command.target.posCannonParent, from: cannon.position, relativeTo: cannon.parent)
        
        // Add missile to playfield
        guard let playfield = root.parent else {
            print("Failed to shoot")
            return nil
        }
        return buildMissile(playfield, command)
    }
    
    private func buildMissile(_ playfield: Entity, _ command: TankCommand) -> Entity {
        // Build and place missile
        let missile = missileTemplate.clone(recursive: true).children[0]
        missile.name = "Missile"
        Collisions.shared.configureMissileCollisions(missile)
        
        let missilePos = cannonShaft.convert(position: .zero, to: playfield)
        missile.position = missilePos
        
        // Add to playfield
        playfield.addChild(missile)
        
        // Point at target
        missile.look(
            at: command.target.posPlayfield,
            from: missile.position,
            upVector: .init(x: 0, y: 1, z: 0),
            relativeTo: missile.parent,
            forward: .positiveZ
        )
        
        // Add to system
        missile.components[ProjectileComponent.self] = ProjectileComponent(
            commandId: command.id,
            target: command.target,
            shooterId: self.id
        )
        return missile
    }
}
