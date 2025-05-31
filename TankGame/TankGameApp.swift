//
//  TankGameApp.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25. 
//

import SwiftUI

@main
struct TankGameApp: App {

    @State private var appModel = AppModel()
    @State private var gameModel = GameModel.shared

    var body: some Scene {
        
        // MARK: - Main Window
        
        WindowGroup {
            MainWindow()
                .environment(appModel)
                .environment(gameModel)
                .frame(
                    minWidth: 800, maxWidth: 800,
                    minHeight: 600, maxHeight: 600
                )
        }
        .windowResizability(.contentSize)
        
        // MARK: - Tank Battleground Full Space

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            TankBattlegroundFullSpace()
                .environment(appModel)
                .environment(gameModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.progressive(0.5...1.0, initialAmount: 1.0)), in: .progressive)
        
        // MARK: - Tank Controls Panel
        
        WindowGroup(id: appModel.tankControlsPanelID) {
            TankControlsPanel()
                .environment(appModel)
                .environment(gameModel)
                .frame(
                    minWidth: 350, maxWidth: 350,
                    minHeight: 450, maxHeight: 450
                )
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)
        .defaultWindowPlacement { content, context in
            return WindowPlacement(.utilityPanel)
        }
        
    }
}
