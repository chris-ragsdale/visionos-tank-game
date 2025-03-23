//
//  TankHealth.swift
//  TankGame
//
//  Created by Chris Ragsdale on 3/23/25.
//

import SwiftUI

struct TankHealth: View {
    var health: Health?
    
    var body: some View {
        if let health {
            HStack {
                ForEach(0..<5) { heartNum in
                    Image(systemName: "heart.fill")
                        .foregroundStyle(heartNum < health.current ? .red : .gray)
                }
                .font(.system(size: 150))
            }
        } else {
            EmptyView()
        }
    }
}
