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
    
    // Shoot
    var shootCooldown: TimeInterval = 0
    var shootInterval: TimeInterval = 3.0
    var shootRange: Float = 5.0
    
    // Move
    var moveCooldown: TimeInterval = 0
    var moveInterval: TimeInterval = 2.0
    var moveRange: Float = 2.5
}

class AISystem: System {
    static var isPaused: Bool = false
    private let query = EntityQuery(where: .has(AIComponent.self))
        
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        guard !Self.isPaused else { return }
        
        let deltaTime = context.deltaTime
        
        guard let playerTank = GameModel.shared.entityManager.playerTank
        else { return }
        
        for aiEntity in context.entities(matching: query, updatingSystemWhen: .rendering) {
            guard var ai = aiEntity.components[AIComponent.self],
                  var aiTank = GameModel.shared.entityManager.enemyTank(ai.tankId)
            else { continue }
            
            // Progress cooldown
            ai.shootCooldown -= deltaTime
            ai.moveCooldown -= deltaTime
            
            let distanceAIPlayer = distance(aiEntity.position, playerTank.root.position)
            
            // Move towards player if outside ideal range and cooldown is ready
            let playerOutsideIdealRange = distanceAIPlayer >= ai.moveRange
            if playerOutsideIdealRange && ai.moveCooldown <= 0 {
                GameModel.shared.commandEnemy(.move, ai.tankId, playerTank)
                ai.moveCooldown = ai.moveInterval
            }
            
            // Shoot at player if within range and cooldown is ready
            let playerInShootingRange = distanceAIPlayer <= ai.shootRange
            if playerInShootingRange && ai.shootCooldown <= 0 {
                GameModel.shared.commandEnemy(.shoot, ai.tankId, playerTank)
                ai.shootCooldown = ai.shootInterval
            }
            
            // Save the updated component back
            aiEntity.components[AIComponent.self] = ai
        }
    }
}
