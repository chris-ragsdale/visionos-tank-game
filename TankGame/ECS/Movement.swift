//
//  Movement.swift
//  TankGame
//
//  Created by Emily Elson on 3/14/25.
//

import RealityKit

struct MovementComponent: Component {
    let velocityMps: Float
    var target: Target
    var firstUpdate: Bool = true
}

class MovementSystem: System {
    static var isPaused: Bool = false
    private let query = EntityQuery(where: .has(MovementComponent.self))
    
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        guard !Self.isPaused else { return }
        
        let deltaTime = Float(context.deltaTime)

        for entity in context.entities(matching: query, updatingSystemWhen: .rendering) {
            guard var movement = entity.components[MovementComponent.self] else { continue }
            
            // Skip first update - prevents shoot forward when moving after not moving for a while
            if movement.firstUpdate {
                movement.firstUpdate = false
                entity.components.set(movement)
                continue
            }
            
            // Take step toward target
            let target = movement.target.posPlayfield
            let direction = simd_normalize(target - entity.position)
            let stepDistance = movement.velocityMps * deltaTime
            let newPos = entity.position + direction * stepDistance
            
            entity.position = newPos

            // Stop if close enough to target
            if simd_distance(newPos, target) < 0.01 {
                entity.components.remove(MovementComponent.self)
            }
        }
    }
}

