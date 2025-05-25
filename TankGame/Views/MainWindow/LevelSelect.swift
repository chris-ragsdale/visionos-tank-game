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
        HStack(spacing: 50) {
            
            // Tutorial
            levelButton(levelIdx: 0)
            
            Divider()
                .frame(height: 125)
            
            VStack {
                HStack {
                    levelButton(levelIdx: 1)
                    levelButton(levelIdx: 2)
                    levelButton(levelIdx: 3)
                }
                HStack {
                    levelButton(levelIdx: 4)
                    levelButton(levelIdx: 5)
                }
            }
        }
        .padding(.top, 25)
    }
    
    @ViewBuilder
    func levelButton(levelIdx: Int) -> some View {
        levelButton(
            level: appModel.levels[levelIdx],
            disabled: levelIdx > 0 ? appModel.levels[levelIdx-1].completionState != .completed : false
        )
    }
    
    @ViewBuilder
    func levelButton(level: Level, disabled: Bool = false) -> some View {
        let icon: some View = level.completionState.icon
        VStack {
            ToggleLevelButton(level: level)
                .disabled(disabled)
            
            icon
                .offset(y: -15)
                .offset(z: 10)
        }
    }
}
