//
//  TankBattlegroundViewModel.swift
//  TankGame
//
//  Created by Emily Elson on 3/9/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

typealias bgEntities = (tank: Entity, environmentRoot: Entity)

@MainActor @Observable
class TankBattlegroundViewModel {
    let battlegroundBase = Entity()
    var moveTargetEntity: Entity?
    var shootTargetEntity: Entity?
    
    var missileTemplate: Entity?
    var explosionEmitter: Entity?
    
    // MARK: - Scene Init
    
    func initBattleground(content: RealityViewContent) async -> bgEntities? {
        // Load USDAs
        guard let missile = try? await Entity(named: "Missile/Missile", in: realityKitContentBundle),
              let battlegroundUSDA = try? await Entity(named: "TankBattleground", in: realityKitContentBundle) else {
            print("Failed to load USDAs")
            return nil
        }
        missileTemplate = missile
        
        // Set up relevant entities in battleground
        guard let tank = battlegroundUSDA.findEntity(named: "Tank"),
              let environmentRoot = battlegroundUSDA.findEntity(named: "EnvironmentRoot"),
              let playfieldGround = battlegroundUSDA.findEntity(named: "PlayfieldGround"),
              let explosionEmitterEntity = battlegroundUSDA.findEntity(named: "ExplosionEmitter") else {
            print("Failed to unpack battleground USDA")
            return nil
        }
        playfieldGround.components[HoverEffectComponent.self] = HoverEffectComponent(.spotlight(.init(color: .white, strength: 1)))
        explosionEmitter = explosionEmitterEntity.clone(recursive: true)
        explosionEmitterEntity.removeFromParent()
        
        battlegroundBase.addChild(battlegroundUSDA)
        content.add(battlegroundBase)
        
        return (tank, environmentRoot)
    }
    
    // MARK: - Gestures
    
    func handlePlayfieldTap(_ event: EntityTargetValue<SpatialTapGesture.Value>, _ appModel: AppModel) {
        let target = Target(
            posBattleground: event.convert(event.location3D, from: .local, to: .scene),
            posPlayfield: event.convert(event.location3D, from: .local, to: appModel.tankEntity.parent!),
            posCannonParent: event.convert(event.location3D, from: .local, to: appModel.tankEntity.findEntity(named: "Cannon")!.parent!)
        )
        
        // Command tank with target
        if let targetEntity = appModel.commandTank(target: target) {
            battlegroundBase.addChild(targetEntity, preservingWorldTransform: false)
        }
    }
    
    // MARK: - Handle Tank Command
    
    func handleNextTankCommand(_ command: TankCommand, _ tank: Entity) {
        switch command.commandType {
        case .move:
            tankMove(tank, command)
        case .shoot:
            tankShoot(tank, command)
        }
    }
    
    private func tankMove(_ tank: Entity, _ command: TankCommand) {
        // Point towards target
        tank.look(at: command.target.posPlayfield, from: tank.position, relativeTo: tank.parent)
        
        // Move towards target (attach movement component)
        tank.components[TankMovementComponent.self] = TankMovementComponent(target: command.target)
    }
    
    private func tankShoot(_ tank: Entity, _ command: TankCommand) {
        // Point cannon towards target
        guard let cannon = tank.findEntity(named: "Cannon") else {
            print("Failed to shoot")
            return
        }
        cannon.look(at: command.target.posCannonParent, from: cannon.position, relativeTo: cannon.parent)
        
        // Shoot missile at target (add missile, attach missile component)
        guard let playfield = tank.parent,
              let cannonShaft = cannon.findEntity(named: "Shaft"),
              let missile = missileTemplate?.clone(recursive: true) else {
            print("Failed to shoot")
            return
        }
        let missilePos = cannonShaft.convert(position: .zero, to: playfield)
        missile.position = missilePos
        playfield.addChild(missile)
        
        missile.look(
            at: command.target.posPlayfield,
            from: missile.position,
            upVector: .init(x: 0, y: 1, z: 0),
            relativeTo: missile.parent,
            forward: .positiveZ
        )
        missile.components[TankMissileComponent.self] = TankMissileComponent(commandId: command.id, target: command.target)
    }
}
