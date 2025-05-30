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
    @Environment(GameModel.self) var gameModel
    
    var body: some View {
        @Bindable var gameModel = gameModel
        VStack {
//            if let levelID = appModel.navPath.last {
//                LevelView(levelID: levelID)
//                    .padding()
//                    .glassBackgroundEffect()
//            }
            
            // Podium Controls
            VStack {
                Text("\(Image(systemName: "square.2.layers.3d.top.filled")) Podium")
                Picker("Podium Behavior", selection: $gameModel.podiumBehavior) {
                    Text("low").tag(PodiumBehavior.floatLow)
                    Text("mid").tag(PodiumBehavior.floatMid)
                    Text("high").tag(PodiumBehavior.floatHigh)
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
            }
            .onChange(of: gameModel.podiumBehavior) { oldBehavior, newBehavior in
                gameModel.updatePodiumBehavior(newBehavior)
            }
            .padding()
            .glassBackgroundEffect()
            
            Spacer()
            
            // Tank Controls
            VStack {
                Text("\(Image(systemName: "target")) Tank Command")
                Picker("Tank Command", selection: $gameModel.selectedCommand) {
                    Text("move").tag(TankCommandType.move)
                    Text("shoot").tag(TankCommandType.shoot)
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
                
                Spacer()
                
                // Missiles
                VStack {
                    HStack {
                        Text("\(Image(systemName: "dot.scope"))")
                        
                        ForEach(0..<3) { missileNum in
                            Image(systemName: "rectangle.portrait.fill")
                                .foregroundStyle(missileNum < gameModel.playerActiveMissiles ? .gray : .red)
                        }
                        
                        Text("\(Image(systemName: "dot.scope"))")
                    }
                    .padding(.top, 2)
                }
            }
            .padding()
            .glassBackgroundEffect()
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
