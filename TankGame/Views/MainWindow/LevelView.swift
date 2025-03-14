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
