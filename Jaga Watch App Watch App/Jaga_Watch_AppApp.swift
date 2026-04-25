//
//  Jaga_Watch_AppApp.swift
//  Jaga Watch App Watch App
//
//  Created by Rigel Sundun Tandilolo on 08/04/26.
//

import SwiftUI

@main
struct Jaga_Watch_App_Watch_AppApp: App {
    // Inisialisasi di sini agar tidak mati saat layar off
    @StateObject private var locationManager = WatchLocationManager()
    @StateObject private var sessionManager = WatchSessionManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .environmentObject(sessionManager)
        }
    }
}
