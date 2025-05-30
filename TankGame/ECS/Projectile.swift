//
//  Projectile.swift
//  TankGame
//
//  Created by Emily Elson on 3/14/25.
//

import RealityKit
import Foundation

struct ProjectileComponent: Component {
    let id: UUID = UUID()
    let velocityMps: Float = 3.5//2.5
    let commandId: TankCommand.ID
    var target: Target
    var firstUpdate: Bool = true
    let shooterId: UUID
}

class ProjectileSystem: System {
    static var isPaused: Bool = false
    private let query = EntityQuery(where: .has(ProjectileComponent.self))
    
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        guard !Self.isPaused else { return }
        
        let deltaTime = Float(context.deltaTime)
        
        for entity in context.entities(matching: query, updatingSystemWhen: .rendering) {
            guard var missile = entity.components[ProjectileComponent.self] else { continue }
            
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
                GameModel.shared.explodeMissile(missile)
            }
        }
    }
}
