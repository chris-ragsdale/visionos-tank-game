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
                Text("\(Image(systemName: "scope")) Tank Command")
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
                        let activeMissiles = gameModel.shootTargetEntities.count
                        ForEach(0..<5) { missileNum in
                            Image(systemName: "rectangle.portrait.fill")
                                .foregroundStyle(missileNum < activeMissiles ? .gray : .red)
                        }
                    }
                    .padding(.top, 2)
                    
                    Text("\(Image(systemName: "dot.scope")) Missiles")
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
