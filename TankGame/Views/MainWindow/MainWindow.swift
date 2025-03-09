//
//  MainWindow.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct MainWindow: View {
    @Environment(AppModel.self) var appModel
    
    let bulletPoint = Image(systemName: "smallcircle.filled.circle")
    
    var body: some View {
        VStack {
            // Title
            Text("Welcome to **Tank Game**")
                .font(.extraLargeTitle)
                .shadow(radius: 10)
            
            overviewCard()
            
            levelList()
                .padding(.top, 25)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 50)
    }
    
    @ViewBuilder
    func overviewCard() -> some View {
        HStack {
            ZStack {
                Image("Tank")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                
                Model3D(named: "Tank/Tank", bundle: realityKitContentBundle) { model in
                    model
                        .model?.resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(width: 200, height: 200)
            }
            
            VStack(alignment: .leading) {
                Text("Tank game is a classic clunky tank game.")
                    .font(.title)
                    .padding(.bottom, 15)
                
                Text("Control a tank using the control panel in front of you.")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                Text("\(bulletPoint)   Directly tap the touchpad to move")
                    .font(.subheadline)
                    .padding(.leading, 10)
                Text("\(bulletPoint)   Indirectly tap the battlefield to shoot")
                    .font(.subheadline)
                    .padding(.leading, 10)
            }
            .padding()
        }
        .background()
        .glassBackgroundEffect()
        .frame(width: 700)
    }
    
    @ViewBuilder
    func levelList() -> some View {
        VStack {
            levelButton(appModel.levels[0])
                .padding(.bottom, 15)
            
            HStack {
                ForEach(appModel.levels) { level in
                    if level != appModel.levels[0] {
                        levelButton(level)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func levelButton(_ level: Level) -> some View {
        let icon: some View = level.completionState.icon
        VStack {
            ToggleLevelButton(levelName: level.name)
            icon
                .offset(y: -15)
                .offset(z: 10)
        }
    }
}

#Preview(windowStyle: .automatic) {
    MainWindow()
        .environment(AppModel())
}
