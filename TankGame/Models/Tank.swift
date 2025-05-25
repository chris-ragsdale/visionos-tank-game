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

@Observable class Tank: Identifiable {
    let id: UUID
    let tankType: TankType
    var health = Health(capacity: 5, current: 5)
    
    // Entities
    let root: Entity
    let cannon: Entity
    let cannonShaft: Entity
    let missileTemplate: Entity
    
    init(_ id: UUID? = nil, _ tankType: TankType, _ root: Entity, _ missileTemplate: Entity) {
        self.id = id ?? UUID()
        self.tankType = tankType
        
        self.root = root
        Collisions.shared.configureTankCollisions(self.root)
        
        // Add enemy AI
        if tankType == .enemy, let id {
            let enemyAI = AIComponent(tankId: id)
            root.components.set(enemyAI)
        }
    
        cannon = root.findEntity(named: "Cannon")!
        cannonShaft = cannon.findEntity(named: "Shaft")!
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
    func handleNextCommand(_ command: TankCommand) -> Entity? {
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
        root.components[TankMovementComponent.self] = TankMovementComponent(target: command.target)
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
        missile.components[TankMissileComponent.self] = TankMissileComponent(commandId: command.id, target: command.target)
        return missile
    }
}
