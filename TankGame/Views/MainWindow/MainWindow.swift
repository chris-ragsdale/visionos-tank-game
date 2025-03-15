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
    
    var body: some View {
        @Bindable var appModel = appModel
        NavigationStack(path: $appModel.navPath) {
            VStack {
                Spacer()
                
                // Title
                Text("Welcome to **Tank Game**")
                    .font(.extraLargeTitle)
                    .shadow(radius: 10)
                
                OverviewCard()
                
                LevelSelect()
                
                Spacer()
            }
            .navigationDestination(for: Level.ID.self) { id in
                LevelView(levelID: id)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 50)
    }
}

#Preview(windowStyle: .automatic) {
    MainWindow()
        .environment(AppModel())
}
