//
//  ContentView.swift
//  stopwatch
//
//  Created by Krishnaswami Rajendren on 12/11/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var stopwatchManager = StopwatchManager()
    @State private var isRunning = false
    @State private var time = "00 : 00 : 00"
    @State private var test = "test"

    
    var body: some View {
        VStack {
            Text(time)
                .font(.system(size: 32, weight: .medium, design: .monospaced))
                .padding()
            
            Button(action: toggleStopwatch) {
                Text(isRunning ? "Stop" : "Start")
                    .foregroundColor(.white)
                    .padding()
                    .background(isRunning ? Color.red : Color.green)
                    .cornerRadius(10)
            }
            Text(test)
        }
        .onAppear {
            stopwatchManager.onTimeUpdate = { [self] (time, message) in
                self.time = time
                self.test = message
            }
        }
        .padding()
    }
    
    private func toggleStopwatch() {
        isRunning.toggle()
        isRunning ? stopwatchManager.start() : stopwatchManager.stop()
    }
}

#Preview {
    ContentView()
}
