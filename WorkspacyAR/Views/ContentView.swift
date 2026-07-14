//
//  ContentView.swift
//  WorkspacyAR
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "table")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Design your desk!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
