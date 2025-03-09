//
//  MainWindow.swift
//  TankGame
//
//  Created by Emily Elson on 3/8/25.
//

import SwiftUI

struct MainWindow: View {
    var body: some View {
        VStack {
            Text("Welcome to **Tank Game**")
                .font(.largeTitle)
                .shadow(radius: 10)
            
            Divider()
            
            ToggleTutorialButton()
                .padding(.top, 25)
        }
    }
}

#Preview(windowStyle: .automatic) {
    MainWindow()
        .environment(AppModel())
}
