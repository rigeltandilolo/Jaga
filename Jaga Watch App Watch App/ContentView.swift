//
//  ContentView.swift
//  Jaga Watch App Watch App
//
//  Created by Rigel Sundun Tandilolo on 08/04/26.
//

import SwiftUI
import WatchKit

struct ContentView: View {
    @EnvironmentObject var locationManager: WatchLocationManager
    @EnvironmentObject var sessionManager: WatchSessionManager

    var dalamZona: Bool { sessionManager.statusZona == "aman" }

    var body: some View {
        ZStack {
            // Warna background berubah sesuai status
            (dalamZona
                ? Color(red: 0.02, green: 0.17, blue: 0.38)
                : Color(red: 0.4, green: 0.0, blue: 0.0))
                .ignoresSafeArea()

            VStack(spacing: 8) {
                Text("jaga")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.22, green: 0.37, blue: 0.64))

                Spacer()

                Image(systemName: dalamZona ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(dalamZona
                        ? Color(red: 0.11, green: 0.62, blue: 0.46)
                        : .yellow)

                Text(dalamZona ? "Aktif" : "PERINGATAN")
                    .font(.headline)
                    .foregroundColor(.white)

                Text(dalamZona
                    ? "Anda terpantau\ndengan aman"
                    : "Anda berada\ndi luar zona aman!")
                    .font(.caption)
                    .foregroundColor(dalamZona ? .gray : .white)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding()
        }
        .persistentSystemOverlays(.hidden)
    }
}

#Preview {
    ContentView()
}
