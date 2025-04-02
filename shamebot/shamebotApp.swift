//
//  shamebotApp.swift
//  shamebot
//
//  Created by Michael Head on 4/1/25.
//

import SwiftUI
import UIKit
import Combine

@main
struct shamebotApp: App {
    @StateObject private var appMonitor = AppMonitor()
    @StateObject private var shameGenerator = ShameGenerator()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appMonitor)
                .environmentObject(shameGenerator)
        }
    }
}

class AppMonitor: ObservableObject {
    @Published var isInstagramActive = false
    @Published var isAuthorized = true // Simplified for demo
    @Published var authorizationError: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private var checkTimer: Timer?
    private var detectionEnabled = true
    
    init() {
        setupNotifications()
        startSimulationTimer()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.checkIfInstagramIsActive()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.stopSimulationTimer()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.startSimulationTimer()
            }
            .store(in: &cancellables)
    }
    
    private func startSimulationTimer() {
        // Stop any existing timer
        stopSimulationTimer()
        
        // Start a new timer that periodically checks
        checkTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.checkIfInstagramIsActive()
        }
    }
    
    private func stopSimulationTimer() {
        checkTimer?.invalidate()
        checkTimer = nil
    }
    
    private func checkIfInstagramIsActive() {
        // This is a simulation function for the demo
        // In a real app with proper permissions, we would use the Screen Time API
        
        // We'll simulate Instagram detection based on the current second
        guard detectionEnabled else { return }
        
        let dateComponent = Calendar.current.component(.second, from: Date())
        let shouldDetect = (dateComponent % 5 == 0) // Detect every 5 seconds
        
        if shouldDetect && !isInstagramActive {
            self.isInstagramActive = true
        }
    }
    
    func resetDetection() {
        isInstagramActive = false
        
        // Temporarily disable detection for a few seconds
        // to avoid immediate re-detection
        detectionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.detectionEnabled = true
        }
    }
    
    func requestAuthorization() {
        // For demo purposes, we simply simulate authorization success
        self.isAuthorized = true
    }
}
