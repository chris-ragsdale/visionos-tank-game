//
//  TankControlsPanel.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI

struct TankControlsPanel: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        VStack {
            
        }
        .padding()
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                appModel.tankControlsOpen = true
            default: break
            }
        }
    }
}
