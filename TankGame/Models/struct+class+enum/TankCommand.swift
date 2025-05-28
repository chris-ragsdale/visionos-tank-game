//
//  TankCommand.swift
//  TankGame
//
//  Created by Emily Elson on 3/9/25.
//

import RealityKit
import Foundation
import SwiftUI

struct TankCommand: Equatable {
    typealias ID = UUID
    
    let id: ID = UUID()
    let tankId: UUID
    let commandType: TankCommandType
    let target: Target
}

enum TankCommandType { case move, shoot }

struct Target: Equatable {
    let posPlayfield: SIMD3<Float>
    let posCannonParent: SIMD3<Float>
    
    // Build target for player
    init(_ playerTank: Tank, _ tapEvent: EntityTargetValue<DragGesture.Value>) {
        posPlayfield = tapEvent.convert(tapEvent.location3D, from: .local, to: playerTank.root.parent!)
        posCannonParent = tapEvent.convert(tapEvent.location3D, from: .local, to: playerTank.cannon.parent!)
    }
    
    // Build target for enemy
    init(_ enemyTank: Tank, _ playerTank: Tank) {
        self.posPlayfield = playerTank.root.position
        posCannonParent = playerTank.root.position(relativeTo: enemyTank.cannon.parent)
    }
}
