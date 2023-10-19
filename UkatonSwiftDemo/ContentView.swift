//
//  ContentView.swift
//  UkatonSwiftDemo
//
//  Created by Zack Qattan on 10/16/23.
//

import SwiftUI
import UkatonKit

struct ContentView: View {
    let ukatonMission = BLEUkatonMission()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Text(ukatonMission.deviceName)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
