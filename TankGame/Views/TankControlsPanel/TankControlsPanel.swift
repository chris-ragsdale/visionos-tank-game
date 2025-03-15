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
            // Podium Controls
            VStack {
                Text("\(Image(systemName: "square.2.layers.3d.top.filled")) Podium")
                Picker("Podium Behavior", selection: $appModel.podiumBehavior) {
                    Text("low").tag(PodiumBehavior.floatLow)
                    Text("mid").tag(PodiumBehavior.floatMid)
                    Text("high").tag(PodiumBehavior.floatHigh)
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
            }
            .onChange(of: appModel.podiumBehavior) { oldBehavior, newBehavior in
                appModel.updatePodiumBehavior(newBehavior)
            }
            .padding()
            .glassBackgroundEffect()
            
            Spacer()
            
            // Tank Controls
            VStack {
                Text("\(Image(systemName: "dot.scope")) Tank Command")
                Picker("Tank Command", selection: $appModel.selectedCommand) {
                    Text("move").tag(TankCommandType.move)
                    Text("shoot").tag(TankCommandType.shoot)
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
                
                Spacer()
                
                // Missiles
                HStack {
                    let activeMissiles = appModel.shootTargetEntities.count
                    ForEach(0..<5) { missileNum in
                        Image(systemName: "rectangle.portrait.fill")
                            .foregroundStyle(missileNum < activeMissiles ? .gray : .red)
                    }
                }
                .padding(.top, 2)
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
