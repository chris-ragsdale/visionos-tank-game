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
    
    @State var dragging: Bool = false
    
    var body: some View {
        @Bindable var appModel = appModel
        VStack {
            Spacer()
            
            // Podium
            Text("\(Image(systemName: "square.2.layers.3d.top.filled")) Podium")
            Picker("Podium Behavior", selection: $appModel.podiumBehavior) {
                Text("low").tag(PodiumBehavior.floatLow)
                Text("mid").tag(PodiumBehavior.floatMid)
                Text("high").tag(PodiumBehavior.floatHigh)
            }
            .pickerStyle(.segmented)
            .frame(width: 350)
            
            Spacer()
            
            // Tank Command
            Text("\(Image(systemName: "switch.2")) Tank Command")
            Picker("Tank Command", selection: $appModel.selectedCommand) {
                Text("move").tag(TankCommandType.move)
                Text("shoot").tag(TankCommandType.shoot)
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
            
            Spacer()
            
            // Missiles
            Text("\(Image(systemName: "flame")) Missiles")
            HStack {
                let activeMissiles = appModel.shootTargetEntities.count
                ForEach(0..<5) { missileNum in
                    Image(systemName: "rectangle.portrait.fill")
                        .foregroundStyle(missileNum < activeMissiles ? .gray : .red)
                }
            }
            .padding(.top, 2)
            
            Spacer()
        }
        .padding()
        .onChange(of: appModel.podiumBehavior) { oldBehavior, newBehavior in
            appModel.updatePodiumBehavior(newBehavior)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                appModel.tankControlsOpen = true
            default: break
            }
        }
    }
}
