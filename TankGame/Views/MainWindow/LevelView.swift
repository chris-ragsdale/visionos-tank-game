//
//  LevelView.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI

struct LevelView: View {
    @Environment(AppModel.self) var appModel
    
    var levelID: Level.ID
    var level: Level {
        appModel.levels[levelID]
    }
    
    var body: some View {
        switch levelID {
        case 0:
            tutorialLevel()
        default:
            EmptyView()
        }
    }
}

extension LevelView {
    @ViewBuilder
    func tutorialLevel() -> some View {
        VStack {
            
            Spacer()
            
            Text(level.description)
            
            Spacer()
        }
        .navigationTitle("Tutorial")
    }
    
    @ViewBuilder
    func level1() -> some View {
        VStack {
//            Text(level.name)
//                .font(.title)
            
            Spacer()
            
            Text(level.description)
            
            Spacer()
        }
        .navigationTitle(level.name)
    }
}

#Preview(windowStyle: .automatic) {
    LevelView(levelID: 0)
        .environment(AppModel())
        .frame(width: 800, height: 600)
}
