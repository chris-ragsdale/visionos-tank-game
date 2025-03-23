//
//  Collisions.swift
//  TankGame
//
//  Created by Chris Ragsdale on 3/22/25.
//

import RealityKit

struct Collisions {
    static let shared = Collisions()
    
    let groundGroup = CollisionGroup(rawValue: 1 << 0)
    let tankGroup = CollisionGroup(rawValue: 1 << 1)
    let missileGroup = CollisionGroup(rawValue: 1 << 2)
    
    let tankFilter: CollisionFilter
    let missileFilter: CollisionFilter
    
    init() {
        tankFilter = CollisionFilter(
            group: tankGroup,
            mask: .all.subtracting(groundGroup)
        )
        missileFilter  = CollisionFilter(
            group: missileGroup,
            mask: .all.subtracting(groundGroup)
        )
    }
}

extension Collisions {
    func configureTankCollisions(_ tankEntity: Entity) {
        guard var tankCollision = tankEntity.components[CollisionComponent.self] else { return }
        tankCollision.mode = .trigger
        tankCollision.filter = Collisions.shared.tankFilter
        tankEntity.components.set(tankCollision)
    }
    
    func configureMissileCollisions(_ missileEntity: Entity) {
        guard var missileCollision = missileEntity.components[CollisionComponent.self] else { return }
        missileCollision.mode = .trigger
        missileCollision.filter = Collisions.shared.missileFilter
        missileEntity.components.set(missileCollision)
    }
}
