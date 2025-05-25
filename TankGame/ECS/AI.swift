//
//  AI.swift
//  TankGame
//
//  Created by Chris Ragsdale on 5/24/25.
//

import RealityKit
import Foundation

struct AIComponent: Component {
    var tankId: UUID
    var shootCooldown: TimeInterval = 0
    var shootInterval: TimeInterval = 3.0  // Shoot every 2 seconds
    var shootRange: Float = 15.0   
}

class AISystem: System {
    private let query = EntityQuery(where: .has(AIComponent.self))
        
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let deltaTime = context.deltaTime
        
        guard let playerTank = GameModel.shared.playerTank else { return }
        for aiEntity in context.entities(matching: query, updatingSystemWhen: .rendering) {
            guard var ai = aiEntity.components[AIComponent.self] else { continue }
            
            // Progress cooldown
            ai.shootCooldown -= deltaTime
            
            // Shoot at player if within range and cooldown is ready
            let playerInShootingRange = distance(aiEntity.position, playerTank.root.position) <= ai.shootRange
            if playerInShootingRange && ai.shootCooldown <= 0 {
                GameModel.shared.commandEnemyShoot(ai.tankId, playerTank)
                ai.shootCooldown = ai.shootInterval
            }
            
            // Save the updated component back
            aiEntity.components[AIComponent.self] = ai
        }
    }
}
