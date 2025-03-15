//
//  Explosion.swift
//  TankGame
//
//  Created by Emily Elson on 3/15/25.
//

import RealityKit
import Foundation

struct ExplosionComponent: Component {}

class ExplosionSystem: System {
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let query = EntityQuery(where: .has(ExplosionComponent.self) && .has(ParticleEmitterComponent.self))
        for entity in context.entities(matching: query, updatingSystemWhen: .rendering) {
            guard let explosion = entity.components[ExplosionComponent.self],
                  let particleEmitter = entity.components[ParticleEmitterComponent.self] else {
                continue
            }
            // TODO: Check for tank hit in explosion radius
        }
    }
}
