//
//  ContentView.swift
//  GameKitExample
//
//  Created by 주환 on 3/26/24.
//

import SwiftUI
import GameKit

struct ContentView: View {
    @EnvironmentObject var gameManager: GameManager
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("\(gameManager.localPlayer.displayName)")
        }
        
        Button(action: {
            gameManager.startMatchmaking()
        }, label: {
            Text("Start Matching")
        })
        
        .padding()
        .onAppear {
            print(gameManager.authenticationState)
            print(PlayerAuthState.authenticated)
            if gameManager.authenticationState != PlayerAuthState.error {
                gameManager.authenticateUser()
            }
        }
    }
}

#Preview {
    ContentView()
}
