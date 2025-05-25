//
//  Level4.swift
//  TankGame
//
//  Created by Chris Ragsdale on 5/24/25.
//

import SwiftUI

struct Level4: View {
    var level: Level
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(level.name)
                .font(.title)
            
            Spacer()
            
            Text(level.description)
            
            Spacer()
            
            ToggleLevelButton(level: level)
            
            Spacer()
        }
    }
}
