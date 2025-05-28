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
        MovementSystem.registerSystem()
        ProjectileSystem.registerSystem()
        ExplosionSystem.registerSystem()
        AISystem.registerSystem()
    }

    var body: some View {
        RealityView { content, attachments in
            await initBattleground(content, attachments)
        } attachments: {
            Attachment(id: "PlayerTankHealth") {
                TankHealth(health: gameModel.playerTank?.health)
            }
            ForEach(gameModel.enemyTanks) { enemyTank in
                Attachment(id: "EnemyTankHealth-\(enemyTank.id)") {
                    TankHealth(health: enemyTank.health)
                }
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0.0)
                .targetedToAnyEntity()
                .onChanged { event in
                    guard !dragging else { return }
                    dragging = true
                    
                    gameModel.commandPlayer(event)
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

extension TankBattlegroundFullSpace {
    func initBattleground(_ content: RealityViewContent, _ attachments: RealityViewAttachments) async {
        // Init entities
        guard let entities = await loadEntities() else { return }
        gameModel.initBattlegroundEntities(entities)
        content.add(gameModel.battlegroundBase)
        
        // Configure attachments and collisions
        configureAttachments(content, attachments)
        gameModel.initCollisionSubs(content)
    }
    
    private func loadEntities() async -> Entities? {
        // Load USDAs
        guard let battlegroundBase = try? await Entity(named: "TankBattleground", in: realityKitContentBundle) else {
            print("Failed to load USDAs")
            return nil
        }
        
        // Load entities from battleground
          guard let environmentRoot = battlegroundBase.findEntity(named: "EnvironmentRoot"),
                let playfield = battlegroundBase.findEntity(named: "Playfield"),
                let playfieldGround = battlegroundBase.findEntity(named: "PlayfieldGround"),
                let explosionEmitterEntity = battlegroundBase.findEntity(named: "ExplosionEmitter") else {
            print("Failed to unpack battleground USDA")
            return nil
        }
        
        // Configure entities
        playfieldGround.components[HoverEffectComponent.self] = HoverEffectComponent(.spotlight(.init(color: .white, strength: 1)))
        explosionEmitterEntity.removeFromParent()
        
        return (battlegroundBase, environmentRoot, playfield, playfieldGround, explosionEmitterEntity)
    }
    
    func configureAttachments(_ content: RealityViewContent, _ attachments: RealityViewAttachments) {
        if let playerTank = gameModel.playerTank {
            attachTankHealth("PlayerTankHealth", playerTank, attachments)
            for enemyTank in gameModel.enemyTanks {
                attachTankHealth("EnemyTankHealth-\(enemyTank.id)", enemyTank, attachments)
            }
        }
    }
    
    private func attachTankHealth(_ attachmentName: String, _ tank: Tank, _ attachments: RealityViewAttachments) {
        guard let healthAttachment = attachments.entity(for: attachmentName),
              let healthAttachmentRoot = tank.root.findEntity(named: "HealthAttachment") else {
            return
        }
        healthAttachment.components.set(BillboardComponent())
        healthAttachmentRoot.addChild(healthAttachment)
    }
}

#Preview(immersionStyle: .progressive) {
    TankBattlegroundFullSpace()
        .environment(AppModel())
}
