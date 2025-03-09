//
//  LevelSelect.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct LevelSelect: View {
    @Environment(AppModel.self) var appModel
    
    var body: some View {
        overviewCard()
        
        // Level List
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
        .padding(.top, 25)
    }
    
    @ViewBuilder
    func overviewCard() -> some View {
        HStack {
            ZStack {
                Image("Tank")
                    .resizable()
                    .scaledToFit()
                    .blur(radius: 4)
                    .frame(width: 200)
                
                Model3D(named: "Tank/Tank", bundle: realityKitContentBundle) { model in
                    model
                        .model?.resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .rotation3DEffect(.degrees(-90), axis: .y)
                .frame(width: 150, height: 150)
                .padding3D(.back, 50)
            }
            
            VStack(alignment: .leading) {
                Text("Tank game is a classic clunky tank game.")
                    .font(.title)
                    .padding(.bottom, 15)
                
                Text("Control a tank using the control panel in front of you.")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                let bulletPoint = Image(systemName: "smallcircle.filled.circle")
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
    func levelButton(_ level: Level) -> some View {
        let icon: some View = level.completionState.icon
        VStack {
            ToggleLevelButton(level: level)
            icon
                .offset(y: -15)
                .offset(z: 10)
        }
    }
}
