//
//  ContentView.swift
//  shamebot
//
//  Created by Michael Head on 4/1/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appMonitor: AppMonitor
    
    var body: some View {
        ZStack {
            // Main app content
            VStack(spacing: 20) {
                Image(systemName: "bell.slash")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                    .font(.system(size: 40))
                
                Text("Instagram Shamer Active")
                    .font(.headline)
                
                Text("This app will show a message when Instagram is opened")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
                
                // For the simplified demo, we assume authorization is always granted
                Text("Demo Mode: Instagram detection is simulated")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                if let error = appMonitor.authorizationError {
                    Text("Error: \(error)")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
            
            // Shame overlay that appears when Instagram is detected
            if appMonitor.isInstagramActive {
                ShameOverlayView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
    }
}

struct ShameOverlayView: View {
    @EnvironmentObject private var appMonitor: AppMonitor
    @EnvironmentObject private var shameGenerator: ShameGenerator
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                if shameGenerator.isLoading {
                    ProgressView()
                        .scaleEffect(2.0)
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .padding(.bottom, 20)
                }
                
                Text(shameGenerator.shameMessage)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let error = shameGenerator.error {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding()
                }
                
                Button("I'll do better") {
                    appMonitor.resetDetection()
                }
                .padding()
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(10)
            }
        }
        .onAppear {
            // Generate a new shame message each time the overlay appears
            shameGenerator.generateShameMessage()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppMonitor())
        .environmentObject(ShameGenerator())
}
