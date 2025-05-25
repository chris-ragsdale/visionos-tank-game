//
//  ToggleLevelButton.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI

struct ToggleLevelButton: View {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    @Environment(AppModel.self) private var appModel
    @Environment(GameModel.self) private var gameModel
    
    var level: Level
    
    var body: some View {
        if appModel.immersiveSpaceState == .open {
            // Exit Level Button
            Button("Exit", action: {
                appModel.setSelectedLevel(nil)
                dismissWindow(id: appModel.tankControlsPanelID)
                toggleImmersiveSpace()
            })
        } else {
            // Play Level Button
            NavigationLink(value: level.id, label: {
                Button(level.name, action: {
                    appModel.setSelectedLevel(level.id)
                    loadLevel(level.id)
                    openWindow(id: appModel.tankControlsPanelID)
                    toggleImmersiveSpace()
                })
            })
            .buttonStyle(.plain)
        }
    }
    
    func loadLevel(_ id: Level.ID) {
        let level = appModel.levels[id]
        gameModel.loadLevel(level)
    }
}

extension ToggleLevelButton {
    func toggleImmersiveSpace() {
        Task { @MainActor in
            switch appModel.immersiveSpaceState {
            case .open:
                appModel.immersiveSpaceState = .inTransition
                await dismissImmersiveSpace()
                // Don't set immersiveSpaceState to .closed because there
                // are multiple paths to ImmersiveView.onDisappear().
                // Only set .closed in ImmersiveView.onDisappear().
                
            case .closed:
                appModel.immersiveSpaceState = .inTransition
                switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                case .opened:
                    // Don't set immersiveSpaceState to .open because there
                    // may be multiple paths to ImmersiveView.onAppear().
                    // Only set .open in ImmersiveView.onAppear().
                    break
                    
                case .userCancelled, .error:
                    // On error, we need to mark the immersive space
                    // as closed because it failed to open.
                    fallthrough
                @unknown default:
                    // On unknown response, assume space did not open.
                    appModel.immersiveSpaceState = .closed
                }
                
            case .inTransition:
                // This case should not ever happen because button is disabled for this case.
                break
            }
        }
    }
}
