//
//  ContentView.swift
//  Flutr
//
//  Created by Adrian Williams on 02/07/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("Connect") {
                print("Boo")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
