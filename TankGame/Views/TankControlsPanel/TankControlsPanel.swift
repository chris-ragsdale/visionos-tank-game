//
//  TankControlsPanel.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct TankControlsPanel: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(AppModel.self) var appModel
    @Environment(GameModel.self) var gameModel
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                podiumControls()
                    .padding(.bottom, 7.5)
                
                tankControls()
                    .padding(.bottom, 7.5)
                
                VStack {
                    TogglePlayStateButton()
                }
                .frame(width: 100, height: 75)
                .padding()
                .glassBackgroundEffect()
            }
            
            if gameModel.playState.notPlaying,
                let levelID = appModel.navPath.last {
                
                VStack {
                    Spacer()
                    
                    LevelView(levelID: levelID)
                        .frame(width: 300, height: 275)
                        .padding()
                        .glassBackgroundEffect()
                }
            }
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
    
    @ViewBuilder
    func podiumControls() -> some View {
        @Bindable var gameModel = gameModel
        VStack {
            Text("\(Image(systemName: "square.2.layers.3d.top.filled")) Podium")
                .font(.title3)
                .padding(.bottom, 5)
            Picker("Podium Behavior", selection: $gameModel.podiumBehavior) {
                Text("low").tag(PodiumBehavior.floatLow)
                Text("mid").tag(PodiumBehavior.floatMid)
                Text("high").tag(PodiumBehavior.floatHigh)
            }
            .pickerStyle(.palette)
            .frame(width: 200, height: 50)
        }
        .onChange(of: gameModel.podiumBehavior) { oldBehavior, newBehavior in
            gameModel.updatePodiumBehavior(newBehavior)
        }
        .padding()
        .glassBackgroundEffect()
    }
    
    @ViewBuilder
    func tankControls() -> some View {
        @Bindable var gameModel = gameModel
        VStack {
            Text("\(Image(systemName: "target")) Tank Command")
                .font(.title3)
                .padding(.bottom, 5)
            Picker("Tank Command", selection: $gameModel.selectedCommand) {
                Text("move").tag(TankCommandType.move)
                Text("shoot").tag(TankCommandType.shoot)
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
            
            Spacer()
            
            HStack {
                missileCell(2)
                missileCell(1)
                missileCell(0)
            }
            .padding(.bottom, 2)
        }
        .frame(height: 150)
        .padding()
        .glassBackgroundEffect()
    }
    
    @ViewBuilder
    func missileCell(_ missileNum: Int) -> some View {
        VStack {
            Model3D(named: "Missile/Rocket", bundle: realityKitContentBundle) { model in
                model
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 50)
            } placeholder: {
                ProgressView()
            }
            .opacity(missileNum > gameModel.playerActiveMissiles-1 ? 1 : 0)
        }
        .frame(width: 30, height: 55)
    }
}
