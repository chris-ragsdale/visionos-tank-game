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
    
    @State var model = TankBattlegroundViewModel()

    var body: some View {
        RealityView { content in
            if let (tank, environmentRoot) = await model.initBattleground(content: content) {
                appModel.tankEntity = tank
                appModel.environmentRoot = environmentRoot
            }
        }
        .onChange(of: appModel.tankCommands) { oldCommands, newCommands in
            guard let command = newCommands.last else { return }
            model.commandTank(command, appModel.tankEntity)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                openWindow(id: appModel.tankControlsPanelID)
            default: break
            }
        }
    }
}

#Preview(immersionStyle: .progressive) {
    TankBattlegroundFullSpace()
        .environment(AppModel())
}
