//
//  TankBattlegroundViewModel.swift
//  TankGame
//
//  Created by Emily Elson on 3/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

@MainActor @Observable
class TankBattlegroundViewModel {
    let battlegroundBase = Entity()
    var tapTargetEntity: Entity?
    
    // MARK: - Scene Init
    
    func initBattleground(content: RealityViewContent) async -> (Entity, Entity)? {
        guard let battlegroundUSDA = try? await Entity(named: "TankBattleground", in: realityKitContentBundle) else { return nil }
        
        let tank = initTank(battlegroundUSDA)
        let environmentRoot = initEnvironmentRoot(battlegroundUSDA)
        let _ = initPlayfieldGround(battlegroundUSDA)
        
        battlegroundBase.addChild(battlegroundUSDA)
        content.add(battlegroundBase)
        
        if let tank, let environmentRoot {
            return (tank, environmentRoot)
        } else {
            return nil
        }
    }
    
    private func initTank(_ battlegroundUSDA: Entity) -> Entity? {
        return battlegroundUSDA.findEntity(named: "Tank")
    }
    
    private func initEnvironmentRoot(_ battlegroundUSDA: Entity) -> Entity? {
        return battlegroundUSDA.findEntity(named: "EnvironmentRoot")
    }
    
    private func initPlayfieldGround(_ battlegroundUSDA: Entity) -> Entity? {
        let playfieldGround = battlegroundUSDA.findEntity(named: "PlayfieldGround")
        playfieldGround?.components[HoverEffectComponent.self] = HoverEffectComponent(.spotlight(.init(color: .white, strength: 1)))
        return playfieldGround
    }
    
    // MARK: - Gestures
    
    func handlePlayfieldTap(_ event: EntityTargetValue<SpatialTapGesture.Value>, _ appModel: AppModel) {
        let tapBattleground = event.convert(event.location3D, from: .local, to: .scene)
        let tapTankParent = event.convert(event.location3D, from: .local, to: appModel.tankEntity.parent!)
        
        // Visualize tap target
        let tapEntity = ModelEntity(
            mesh: .generateSphere(radius: 0.1),
            materials: [SimpleMaterial(color: .white, roughness: 0.1, isMetallic: false)]
        )
        tapEntity.setPosition(tapBattleground, relativeTo: nil)
        battlegroundBase.addChild(tapEntity, preservingWorldTransform: false)
        
        // Clear old target and store new
        tapTargetEntity?.removeFromParent()
        tapTargetEntity = tapEntity
        
        // Command tank with target
        appModel.commandTank(target: tapTankParent)
    }
    
    // MARK: - Handle Tank Command
    
    func handleNextTankCommand(_ command: TankCommand, _ tank: Entity) {
        switch command.commandType {
        case .move:
            tankMove(tank, command.target)
        case .shoot:
            tankShoot(tank, command.target)
        }
    }
    
    private func tankMove(_ tank: Entity, _ target: SIMD3<Float>) {
        // Point towards target
        tank.look(at: target, from: tank.position, relativeTo: tank.parent)
        
        // Move (attach movement component)
        tank.components[TankMovementComponent.self] = TankMovementComponent(target: target)
    }
    
    private func tankShoot(_ tank: Entity, _ target: SIMD3<Float>) {
        // TODO: Point cannon towards target
        // TODO: Shoot (create missile entity, attach missile component)
    }
}
