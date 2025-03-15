//
//  TankCommand.swift
//  TankGame
//
//  Created by Emily Elson on 3/9/25.
//

import RealityKit
import Foundation

struct TankCommand: Equatable {
    typealias ID = UUID
    
    let id: ID = UUID()
    let commandType: TankCommandType
    let target: Target
}

enum TankCommandType { case move, shoot }

struct Target: Equatable {
    let posBattleground: SIMD3<Float>
    let posPlayfield: SIMD3<Float>
    let posCannonParent: SIMD3<Float>
}
