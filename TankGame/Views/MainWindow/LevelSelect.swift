//
//  LevelSelect.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct LevelSelect: View {
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        // Level List
        VStack {
            levelButton(appModel.levels[0])
                .padding(.bottom, 15)
            
            HStack {
                ForEach(appModel.levels) { level in
                    if level != appModel.levels[0] {
                        levelButton(level)
                    }
                }
            }
        }
        .padding(.top, 25)
    }
    
    @ViewBuilder
    func levelButton(_ level: Level) -> some View {
        let icon: some View = level.completionState.icon
        VStack {
            ToggleLevelButton(level: level)
            icon
                .offset(y: -15)
                .offset(z: 10)
        }
    }
}
