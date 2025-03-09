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
    
    // MARK: - Scene Init
    
    func initBattleground(content: RealityViewContent) async -> (Entity, Entity)? {
        if let battlegroundUSDA = try? await Entity(named: "TankBattleground", in: realityKitContentBundle) {
            let tank = initTank(battlegroundUSDA)
            let environmentRoot = initEnvironmentRoot(battlegroundUSDA)
            
            battlegroundBase.addChild(battlegroundUSDA)
            content.add(battlegroundBase)
            
            if let tank, let environmentRoot {
                return (tank, environmentRoot)
            }
        }
        return nil
    }
    
    private func initTank(_ battlegroundUSDA: Entity) -> Entity? {
        return battlegroundUSDA.findEntity(named: "Tank")
    }
    
    private func initEnvironmentRoot(_ battlegroundUSDA: Entity) -> Entity? {
        return battlegroundUSDA.findEntity(named: "EnvironmentRoot")
    }
    
    // MARK: - Handle Tank Command
    
    func commandTank(_ command: TankCommand, _ tank: Entity) {
        switch command.commandType {
        case .move:
            tankMove(tank, command.target)
        case .shoot:
            tankShoot(tank, command.target)
        }
    }
    
    private func tankMove(_ tank: Entity, _ target: SIMD3<Float>) {
        var newTransform = tank.transform
        newTransform.translation.y = newTransform.translation.y + 10
        tank.move(to: newTransform, relativeTo: tank.parent, duration: 10)
    }
    
    private func tankShoot(_ tank: Entity, _ target: SIMD3<Float>) {
        
    }
}
