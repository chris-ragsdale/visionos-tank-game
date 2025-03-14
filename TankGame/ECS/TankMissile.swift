//
//  TankMissile.swift
//  TankGame
//
//  Created by Emily Elson on 3/14/25.
//

import RealityKit

struct TankMissileComponent: Component {
    let velocityMps: Float = 0.1
    var target: SIMD3<Float>
}

class TankMissileSystem: System {
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)

        let query = EntityQuery(where: .has(TankMissileComponent.self))
        for entity in context.entities(matching: query, updatingSystemWhen: .rendering) {
            guard let movement = entity.components[TankMissileComponent.self] else { continue }

            let direction = simd_normalize(movement.target - entity.position)
            let stepDistance = movement.velocityMps * deltaTime

            let newPos = entity.position + direction * stepDistance
            entity.position = newPos

            // Stop if close enough to target
            if simd_distance(newPos, movement.target) < 0.01 {
                entity.components.remove(TankMissileComponent.self)
            }
        }
    }
}
