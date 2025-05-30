//
//  LevelView.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI

struct LevelView: View {
    @Environment(AppModel.self) var appModel
    @Environment(GameModel.self) var gameModel
    
    var levelID: Level.ID
    var level: Level {
        appModel.levels[levelID]
    }
    
    var body: some View {
        Group {
            switch levelID {
            case 0:
                Tutorial(level: level)
            case 1:
                Level1(level: level)
            case 2:
                Level2(level: level)
            case 3:
                Level3(level: level)
            case 4:
                Level4(level: level)
            case 5:
                Level5(level: level)
            default:
                EmptyView()
            }
        }
        .toolbar(.hidden)
    }
}

#Preview(windowStyle: .automatic) {
    LevelView(levelID: 0)
        .environment(AppModel())
        .frame(width: 800, height: 600)
}
