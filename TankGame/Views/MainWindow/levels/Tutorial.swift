//
//  Tutorial.swift
//  TankGame
//
//  Created by Chris Ragsdale on 5/24/25.
//

import SwiftUI

struct Tutorial: View {
    @Environment(GameModel.self) private var gameModel
    var level: Level
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(level.name)
                .font(.title)
            
            Spacer()
            
            Text(level.description)
            
            Spacer()
            
            HStack(spacing: 50) {
                TogglePlayStateButton()
                ToggleLevelButton(level: level)
            }
            
            Spacer()
        }
    }
}
