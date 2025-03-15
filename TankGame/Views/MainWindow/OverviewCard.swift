//
//  OverviewCard.swift
//  TankGame
//
//  Created by Emily Elson on 3/14/25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct OverviewCard: View {
    var body: some View {
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
                .rotation3DEffect(.degrees(90), axis: .y)
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
}
