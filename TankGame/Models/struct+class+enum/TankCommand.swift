//
//  TankCommand.swift
//  TankGame
//
//  Created by Emily Elson on 3/9/25.
//

import RealityKit

enum TankCommandType {
    case move, shoot
}
struct TankCommand: Equatable {
    let commandType: TankCommandType
    let target: SIMD3<Float>
}
