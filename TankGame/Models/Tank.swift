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

class Tank {
    let root: Entity
    let cannon: Entity
    let cannonShaft: Entity
    let missileTemplate: Entity
    
    init(_ root: Entity, _ missileTemplate: Entity) {
        self.root = root
        cannon = root.findEntity(named: "Cannon")!
        cannonShaft = cannon.findEntity(named: "Shaft")!
        self.missileTemplate = missileTemplate
    }
}
 
extension Tank {
    func handleNextCommand(_ command: TankCommand) {
        switch command.commandType {
        case .move:
            move(command)
        case .shoot:
            shoot(command)
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
    private func shoot(_ command: TankCommand) {
        // Point cannon towards target
        cannon.look(at: command.target.posCannonParent, from: cannon.position, relativeTo: cannon.parent)
        
        // Add missile to playfield
        guard let playfield = root.parent else {
            print("Failed to shoot")
            return
        }
        let missile = missileTemplate.clone(recursive: true)
        let missilePos = cannonShaft.convert(position: .zero, to: playfield)
        missile.position = missilePos
        playfield.addChild(missile)
        
        // Point missile at target
        missile.look(
            at: command.target.posPlayfield,
            from: missile.position,
            upVector: .init(x: 0, y: 1, z: 0),
            relativeTo: missile.parent,
            forward: .positiveZ
        )
        
        // Start moving missile
        missile.components[TankMissileComponent.self] = TankMissileComponent(commandId: command.id, target: command.target)
    }
}
