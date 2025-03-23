//
//  TankMissile.swift
//  TankGame
//
//  Created by Emily Elson on 3/14/25.
//

import RealityKit
import Foundation

struct TankMissileComponent: Component {
    let id: UUID = UUID()
    let velocityMps: Float = 2.5
    let commandId: TankCommand.ID
    var target: Target
    var firstUpdate: Bool = true
}

class TankMissileSystem: System {
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)

        let query = EntityQuery(where: .has(TankMissileComponent.self))
        for entity in context.entities(matching: query, updatingSystemWhen: .rendering) {
            guard var missile = entity.components[TankMissileComponent.self] else { continue }
            
            // Skip first update - prevents shoot forward when moving after not moving for a while
            if missile.firstUpdate {
                missile.firstUpdate = false
                entity.components.set(missile)
                continue
            }
            
            // Take step toward target
            let target = missile.target.posPlayfield
            let direction = simd_normalize(target - entity.position)
            let stepDistance = missile.velocityMps * deltaTime
            let newPos = entity.position + direction * stepDistance
            
            entity.position = newPos

            // Explode if close enough to target
            if simd_distance(newPos, target) < 0.015 {
                GameModel.shared.handleMissileHit(entity, missile)
                continue
            }
            
            // Explode if close enough to tank
//            guard let enemyTank = GameModel.shared.enemyTank else { continue }
//            handleMissileHit(entity, missile)
        }
    }
}
