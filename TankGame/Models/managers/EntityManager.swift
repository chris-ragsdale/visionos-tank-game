//
//  EntityManager.swift
//  TankGame
//
//  Created by Chris Ragsdale on 6/4/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

typealias TankMaterials = (
    bodyPaintEnemy: ShaderGraphMaterial,
    cannonPaintEnemy: ShaderGraphMaterial,
    roadwheelPaintEnemy: ShaderGraphMaterial
)

@Observable
class EntityManager {
    var playerTank: Tank?
    var enemyTanks: [Tank] = []
    
    func enemyTank(_ id: UUID) -> Tank? {
        enemyTanks.first { $0.id == id }
    }
    
    // Templates
    var missileTemplate: Entity?
    var tankTemplate: Entity?
    var tankMaterials: TankMaterials?
    
    // Scene References
    var battlegroundBase = Entity()
    var playfield = Entity()
    var environmentRoot: Entity?
    
    init() {
        Task {
            // Load USDA templates
            self.missileTemplate = try? await Entity(
                named: "Missile/Missile",
                in: realityKitContentBundle
            )
            self.tankTemplate = try? await Entity(
                named: "Tank/Tank",
                in: realityKitContentBundle
            )
            
            // Load tank materials
            let bodyPaintEnemy = try? await ShaderGraphMaterial(
                named: "/Root/TankRoot/BodyPaintEnemy",
                from: "Tank/Tank.usda",
                in: realityKitContentBundle
            )
            let cannonPaintEnemy = try? await ShaderGraphMaterial(
                named: "/Root/TankRoot/CannonPaintEnemy",
                from: "Tank/Tank.usda",
                in: realityKitContentBundle
            )
            let roadwheelPaintEnemy = try? await ShaderGraphMaterial(
                named: "/Root/TankRoot/RoadwheelPaintEnemy",
                from: "Tank/Tank.usda",
                in: realityKitContentBundle
            )
            
            guard let bodyPaintEnemy, let cannonPaintEnemy, let roadwheelPaintEnemy
            else { return }
            
            self.tankMaterials = (bodyPaintEnemy, cannonPaintEnemy, roadwheelPaintEnemy)
        }
    }
    
    func buildTank(_ tankType: TankType, _ position: SIMD3<Float>, _ id: UUID? = nil) -> Tank? {
        guard let tankTemplate, let missileTemplate, let tankMaterials else {
            print("Failed to build tank, entity templates not yet available")
            return nil
        }
        
        let tankEntity = tankTemplate.clone(recursive: true).children[0]
        tankEntity.position = position
        return Tank(id, tankType, tankEntity, missileTemplate, tankMaterials)
    }
}
