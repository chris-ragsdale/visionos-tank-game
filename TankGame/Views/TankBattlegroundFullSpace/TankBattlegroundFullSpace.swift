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
    
    @State var dragging = false
    
    init() {
        TankMovementSystem.registerSystem()
        TankMissileSystem.registerSystem()
        ExplosionSystem.registerSystem()
    }

    var body: some View {
        RealityView { content in
            await initBattleground(content)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0.0)
                .targetedToAnyEntity()
                .onChanged { event in
                    guard !dragging else { return }
                    dragging = true
                    
                    gameModel.targetTappedPosition(event)
                }
                .onEnded { event in
                    dragging = false
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
        // Load and configure entities
        guard let entities = await loadEntities() else { return }
        entities.playfieldGround.components[HoverEffectComponent.self] = HoverEffectComponent(.spotlight(.init(color: .white, strength: 1)))
        entities.explosionEmitterEntity.removeFromParent()
        
        // Add bg to view
        content.add(gameModel.battlegroundBase)
        
        // Save entities to game model
        gameModel.initEntities(entities)
        
        let playerTankSub = content.subscribe(to: CollisionEvents.Began.self, on: gameModel.tank!.root) { event in
            print("Player Tank Hit!")
            print("entityA: \(event.entityA.name)")
            print("entityB: \(event.entityB.name)")
            print("-+-+-+-+-+-+-")
        }
        let enemyTankSub = content.subscribe(to: CollisionEvents.Began.self, on: gameModel.enemyTank!.root) { event in
            print("Enemy Tank Hit!")
            print("entityA: \(event.entityA.name)")
            print("entityB: \(event.entityB.name)")
            print("-+-+-+-+-+-+-")
        }
        gameModel.collisionSubscriptions.append(playerTankSub)
        gameModel.collisionSubscriptions.append(enemyTankSub)
    }
    
    func loadEntities() async -> Entities? {
        // Load USDAs
        guard let missileTemplate = try? await Entity(named: "Missile/Missile", in: realityKitContentBundle),
              let battlegroundUSDA = try? await Entity(named: "TankBattleground", in: realityKitContentBundle) else {
            print("Failed to load USDAs")
            return nil
        }
        
        // Load entities from battleground
        guard let playerTankRoot = battlegroundUSDA.findEntity(named: "PlayerTank"),
              let enemyTankRoot = battlegroundUSDA.findEntity(named: "EnemyTank"),
              let environmentRoot = battlegroundUSDA.findEntity(named: "EnvironmentRoot"),
              let playfieldGround = battlegroundUSDA.findEntity(named: "PlayfieldGround"),
              let explosionEmitterEntity = battlegroundUSDA.findEntity(named: "ExplosionEmitter") else {
            print("Failed to unpack battleground USDA")
            return nil
        }
        
        return (missileTemplate, battlegroundUSDA, playerTankRoot, enemyTankRoot, environmentRoot, playfieldGround, explosionEmitterEntity)
    }
}

typealias Entities = (
    missileTemplate: Entity,
    battlegroundUSDA: Entity,
    playerTankRoot: Entity,
    enemyTankRoot: Entity,
    environmentRoot: Entity,
    playfieldGround: Entity,
    explosionEmitterEntity: Entity
)

#Preview(immersionStyle: .progressive) {
    TankBattlegroundFullSpace()
        .environment(AppModel())
}
