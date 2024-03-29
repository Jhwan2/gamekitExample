//
//  GameKitExampleApp.swift
//  GameKitExample
//
//  Created by 주환 on 3/26/24.
//

import SwiftUI

@main
struct GameKitExampleApp: App {
    @StateObject private var gameManager = GameManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameManager)
        }
    }
}
