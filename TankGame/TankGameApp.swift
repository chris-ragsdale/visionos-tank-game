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

    var body: some Scene {
        
        // MARK: - Main Window
        
        WindowGroup {
            MainWindow()
                .environment(appModel)
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
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
        
        // MARK: - Tank Controls Panel
        
        WindowGroup(id: "TankControlsPanel") {
            TankControlsPanel()
                .environment(appModel)
                .frame(
                    minWidth: 500, maxWidth: 500,
                    minHeight: 500, maxHeight: 500
                )
        }
        .windowResizability(.contentSize)
        .defaultWindowPlacement { content, context in
            return WindowPlacement(.utilityPanel)
        }
        
    }
}
