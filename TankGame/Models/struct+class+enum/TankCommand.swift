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
    let commandType: TankCommandType
    let target: Target
}

enum TankCommandType { case move, shoot }

struct Target: Equatable {
    let posPlayfield: SIMD3<Float>
    let posCannonParent: SIMD3<Float>
    
    init(_ tapEvent: EntityTargetValue<DragGesture.Value>, _ tank: Tank?) {
        posPlayfield = tapEvent.convert(tapEvent.location3D, from: .local, to: tank!.root.parent!)
        posCannonParent = tapEvent.convert(tapEvent.location3D, from: .local, to: tank!.cannon.parent!)
    }
}
