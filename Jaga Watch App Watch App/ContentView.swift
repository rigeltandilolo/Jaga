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

    @State private var pulseScale1: CGFloat = 1.0
    @State private var pulseScale2: CGFloat = 1.0
    @State private var pulseOpacity1: Double = 0.4
    @State private var pulseOpacity2: Double = 0.25

    var body: some View {
        ZStack {
//            // Background putih bersih
//            Color.white.ignoresSafeArea()

            VStack(spacing: 6) {
                // Logo
                Text("JAGA")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(dalamZona
                        ? Color(red: 0.22, green: 0.37, blue: 0.64)
                        : Color(red: 0.75, green: 0.1, blue: 0.1))

                Spacer()

                // Lingkaran pulse + icon
                ZStack {
                    // Pulse layer 2 (paling luar)
                    Circle()
                        .fill(dalamZona
                            ? Color(red: 0.75, green: 0.87, blue: 0.97)
                            : Color(red: 1.0, green: 0.75, blue: 0.75))
                        .frame(width: 90, height: 90)
                        .scaleEffect(pulseScale2)
                        .opacity(pulseOpacity2)

                    // Pulse layer 1 (tengah)
                    Circle()
                        .fill(dalamZona
                            ? Color(red: 0.65, green: 0.82, blue: 0.95)
                            : Color(red: 1.0, green: 0.6, blue: 0.6))
                        .frame(width: 90, height: 90)
                        .scaleEffect(pulseScale1)
                        .opacity(pulseOpacity1)

                    // Lingkaran utama
                    Circle()
                        .fill(dalamZona
                            ? Color(red: 0.78, green: 0.9, blue: 0.98)
                            : Color(red: 1.0, green: 0.82, blue: 0.82))
                        .frame(width: 80, height: 80)

                    // Icon
                    if dalamZona {
                        Image(systemName: "applewatch.radiowaves.left.and.right")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.65))
                    } else {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 30, weight: .medium))
                            .foregroundColor(Color(red: 0.85, green: 0.1, blue: 0.1))
                    }
                }

                Spacer()

                // Teks status
                if dalamZona {
                    Text("Sedang memantau")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.65))
                        .multilineTextAlignment(.center)
                } else {
                    Text("Kembali ke Zona Aman!")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.8, green: 0.05, blue: 0.05))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .onAppear {
            startPulseAnimation()
        }
        .onChange(of: dalamZona) { _ in
            // Reset dan mulai ulang animasi saat status berubah
            pulseScale1 = 1.0
            pulseScale2 = 1.0
            pulseOpacity1 = 0.4
            pulseOpacity2 = 0.25
            startPulseAnimation()
        }
        .animation(.easeInOut(duration: 0.5), value: dalamZona)
        .persistentSystemOverlays(.hidden)
    }

    private func startPulseAnimation() {
        // Layer 1 — lebih cepat
        withAnimation(
            .easeInOut(duration: 1.4)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale1 = 1.18
            pulseOpacity1 = 0.15
        }

        // Layer 2 — lebih lambat, delay sedikit
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(
                .easeInOut(duration: 1.8)
                .repeatForever(autoreverses: true)
            ) {
                pulseScale2 = 1.32
                pulseOpacity2 = 0.08
            }
        }
    }
}

#Preview {
    ContentView()
}
