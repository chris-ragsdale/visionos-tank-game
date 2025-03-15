//
//  TankBattlegroundFullSpace.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct TankBattlegroundFullSpace: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.openWindow) var openWindow
    @Environment(AppModel.self) var appModel
    @Environment(GameModel.self) var gameModel
    
    init() {
        TankMovementSystem.registerSystem()
        TankMissileSystem.registerSystem()
        ExplosionSystem.registerSystem()
    }

    var body: some View {
        RealityView { content in
            await initBattleground(content)
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { event in
                    gameModel.targetTappedPosition(event)
                }
        )
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                openWindow(id: appModel.tankControlsPanelID)
            default: break
            }
        }
    }
    
    func initBattleground(_ content: RealityViewContent) async {
        // Load USDAs
        guard let missileTemplate = try? await Entity(named: "Missile/Missile", in: realityKitContentBundle),
              let battlegroundUSDA = try? await Entity(named: "TankBattleground", in: realityKitContentBundle) else {
            print("Failed to load USDAs")
            return
        }
        
        // Set up battleground entities
        guard let tankRoot = battlegroundUSDA.findEntity(named: "Tank"),
              let environmentRoot = battlegroundUSDA.findEntity(named: "EnvironmentRoot"),
              let playfieldGround = battlegroundUSDA.findEntity(named: "PlayfieldGround"),
              let explosionEmitterEntity = battlegroundUSDA.findEntity(named: "ExplosionEmitter") else {
            print("Failed to unpack battleground USDA")
            return
        }
        playfieldGround.components[HoverEffectComponent.self] = HoverEffectComponent(.spotlight(.init(color: .white, strength: 1)))
        explosionEmitterEntity.removeFromParent()
        
        // Set bg entities to game model
        gameModel.tank = Tank(tankRoot, missileTemplate)
        gameModel.environmentRoot = environmentRoot
        gameModel.explosionEmitter = explosionEmitterEntity.components[ParticleEmitterComponent.self]
        
        // Add bg to view
        gameModel.battlegroundBase.addChild(battlegroundUSDA)
        content.add(gameModel.battlegroundBase)
    }
}

#Preview(immersionStyle: .progressive) {
    TankBattlegroundFullSpace()
        .environment(AppModel())
}
