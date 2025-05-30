//
//  TogglePlayStateButton.swift
//  TankGame
//
//  Created by Chris Ragsdale on 5/30/25.
//

import SwiftUI

typealias ButtonConfig = (name: String, icon: String, color: Color)

struct TogglePlayStateButton: View {
    @Environment(GameModel.self) private var gameModel
    
    var buttonConfig: ButtonConfig {
        switch gameModel.playState {
        case .ready: ("Start", "play", .blue)
        case .playing: ("Pause", "pause", .yellow)
        case .paused: ("Play", "play", .green)
        }
    }
    
    var body: some View {
        let (name, icon, color) = buttonConfig
        Button(name, systemImage: icon) {
            switch gameModel.playState {
            case .ready: gameModel.setPlayState(.playing)
            case .playing: gameModel.setPlayState(.paused)
            case .paused: gameModel.setPlayState(.playing)
            }
        }
        .background(color)
        .glassBackgroundEffect()
    }
}
