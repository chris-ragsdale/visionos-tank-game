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
        RealityView { content, attachments in
            await initBattleground(content, attachments)
        } attachments: {
            Attachment(id: "PlayerTankHealth") {
                TankHealth(health: gameModel.playerTank?.health)
            }
            Attachment(id: "EnemyTankHealth") {
                TankHealth(health: gameModel.enemyTank?.health)
            }
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
}

typealias Entities = (
    missileTemplate: Entity,
    battlegroundBase: Entity,
    playerTankRoot: Entity,
    enemyTankRoot: Entity,
    environmentRoot: Entity,
    playfield: Entity,
    playfieldGround: Entity,
    explosionEmitterEntity: Entity
)

extension TankBattlegroundFullSpace {
    func initBattleground(_ content: RealityViewContent, _ attachments: RealityViewAttachments) async {
        // Load and configure entities
        guard let entities = await loadEntities() else { return }
        
        // Init game model
        gameModel.initEntities(entities)
        gameModel.initCollisionSubs(content)
        
        // Add bg to view
        content.add(gameModel.battlegroundBase)
        
        // Configure tank health attachments
        configureTankHealthAttachments(attachments)
    }
    
    private func loadEntities() async -> Entities? {
        // Load USDAs
        guard let missileTemplate = try? await Entity(named: "Missile/Missile", in: realityKitContentBundle),
              let battlegroundBase = try? await Entity(named: "TankBattleground", in: realityKitContentBundle) else {
            print("Failed to load USDAs")
            return nil
        }
        
        // Load entities from battleground
        guard let playerTankRoot = battlegroundBase.findEntity(named: "PlayerTank"),
              let enemyTankRoot = battlegroundBase.findEntity(named: "EnemyTank"),
              let environmentRoot = battlegroundBase.findEntity(named: "EnvironmentRoot"),
              let playfield = battlegroundBase.findEntity(named: "Playfield"),
              let playfieldGround = battlegroundBase.findEntity(named: "PlayfieldGround"),
              let explosionEmitterEntity = battlegroundBase.findEntity(named: "ExplosionEmitter") else {
            print("Failed to unpack battleground USDA")
            return nil
        }
        
        // Configure entities
        playfieldGround.components[HoverEffectComponent.self] = HoverEffectComponent(.spotlight(.init(color: .white, strength: 1)))
        explosionEmitterEntity.removeFromParent()
        
        return (missileTemplate, battlegroundBase, playerTankRoot, enemyTankRoot, environmentRoot, playfield, playfieldGround, explosionEmitterEntity)
    }
    
    private func configureTankHealthAttachments(_ attachments: RealityViewAttachments) {
        if let playerHealthAttachment = attachments.entity(for: "PlayerTankHealth"),
           let playerHealthAttachmentRoot = gameModel.playerTank?.root.findEntity(named: "HealthAttachment") {
            playerHealthAttachment.components.set(BillboardComponent())
            playerHealthAttachmentRoot.addChild(playerHealthAttachment)
        }
        
        if let enemyHealthAttachment = attachments.entity(for: "EnemyTankHealth"),
           let enemyHealthAttachmentRoot = gameModel.enemyTank?.root.findEntity(named: "HealthAttachment") {
            enemyHealthAttachment.components.set(BillboardComponent())
            enemyHealthAttachmentRoot.addChild(enemyHealthAttachment)
        }
    }
}

#Preview(immersionStyle: .progressive) {
    TankBattlegroundFullSpace()
        .environment(AppModel())
}
