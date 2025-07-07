//
//  ContentView.swift
//  Flutr
//
//  Created by Adrian Williams on 02/07/2025.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var wsManager: WebSocketManager
        
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Button(action: connectWS) {
                    Label("Connect WS", systemImage: "point.3.connected.trianglepath.dotted")
                }
                Button(action: disconnectWS) {
                    Label("Disconnect WS", systemImage: "point.3.connected.trianglepath.dotted")
                }
                Button(action: {Task {
                    await bounceMessage()
                }}) {
                    Label("Send message", systemImage: "point.3.connected.trianglepath.dotted")
                }
            }
            .padding()
            ScrollView(.vertical, showsIndicators: true) {
                Text(wsManager.messageLog)
//                    .lineLimit(12)
            }
            .padding(.all)
        }
//        .onAppear {
//            wsManager.connect()
//        }
        .onDisappear() {
            print("Disappearing...")
            wsManager.disconnect()
        }
    }
    
    private func connectWS() {
        print("Connecting to WS...")
        wsManager.connect()
    }
    
    private func disconnectWS() {
        print("Connecting to WS...")
        wsManager.disconnect()
    }
    
    private func bounceMessage() async {
        if wsManager.isConnected {
            try? await wsManager.sendTextMessage( "\(UUID()): Hi.")
        } else {
            print("Connection not open yet...")
        }
    }
}


#Preview {
    ContentView()
}
