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
                Text("Low").tag(PodiumBehavior.floatLow)
                Text("Mid").tag(PodiumBehavior.floatMid)
                Text("High").tag(PodiumBehavior.floatHigh)
            }
            .pickerStyle(.segmented)
            .frame(width: 350)
            
            Spacer()
            
            // Tank Command
            Text("\(Image(systemName: "switch.2")) Tank Command")
            Picker("Tank Command", selection: $appModel.selectedTankCommand) {
                Text("move").tag(TankCommandType.move)
                Text("shoot").tag(TankCommandType.shoot)
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
            
//            // Touchpad
//            Text("\(Image(systemName: "move.3d")) Move")
//            RoundedRectangle(cornerRadius: 25)
//                .fill(.gray.opacity(0.4))
//                .frame(width: 300, height: 300)
//                .gesture (
//                    DragGesture()
//                        .onChanged { value in
//                            guard dragging == false else { return }
//                            dragging = true
////                            moveTank(dragValue: value)
//                        }
//                        .onEnded { value in
//                            dragging = false
//                        }
//                )
//                .hoverEffect()
            
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
    
//    func moveTank(dragValue: DragGesture.Value) {
//        let command = TankCommand(commandType: .move, target: .zero)
//        appModel.tankCommands.append(command)
//    }
}
