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
            levelButton(level: appModel.levels[0])
            
            Divider()
                .frame(height: 125)
            
            VStack {
                HStack {
                    levelButton(
                        level: appModel.levels[1],
                        disabled: appModel.levels[0].completionState != .completed
                    )
                    levelButton(
                        level: appModel.levels[2],
                        disabled: appModel.levels[1].completionState != .completed
                    )
                    levelButton(
                        level: appModel.levels[3],
                        disabled: appModel.levels[2].completionState != .completed
                    )
                }
                HStack {
                    levelButton(
                        level: appModel.levels[4],
                        disabled: appModel.levels[3].completionState != .completed
                    )
                    levelButton(
                        level: appModel.levels[5],
                        disabled: appModel.levels[4].completionState != .completed
                    )
                }
            }
        }
        .padding(.top, 25)
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
