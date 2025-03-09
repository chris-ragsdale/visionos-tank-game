//
//  TankGameApp.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI

@main
struct TankGameApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environment(appModel)
                .frame(
                    minWidth: 800, maxWidth: 800,
                    minHeight: 600, maxHeight: 600
                )
        }
        .windowResizability(.contentSize)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.full), in: .full)
    }
}
