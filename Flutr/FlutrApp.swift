//
//  FlutrApp.swift
//  Flutr
//
//  Created by Adrian Williams on 02/07/2025.
//

import SwiftUI

@main
struct FlutrApp: App {

    @StateObject private var wsManager = WebSocketManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(wsManager)
        }
    }
}



