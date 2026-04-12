//
//  ContentView.swift
//  Jaga Watch App Watch App
//
//  Created by Rigel Sundun Tandilolo on 08/04/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = WatchLocationManager()
    @StateObject private var sessionManager = WatchSessionManager.shared
    
    var body: some View {
        ZStack {
            Color(red: 0.02, green: 0.17, blue: 0.38)
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                // Logo
                Text("jaga")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.22, green: 0.37, blue: 0.64))
                
                Spacer()
                
                // Status icon
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 36))
                    .foregroundColor(Color(red: 0.11, green: 0.62, blue: 0.46))
                
                // Status text
                Text("Aktif")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Anda terpantau\ndengan aman")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
