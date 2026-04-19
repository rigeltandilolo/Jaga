//
//  PantauView.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 11/04/26.
//

import SwiftUI
import MapKit

struct PantauView: View {
    @Binding var selectedTab: Int
    @StateObject private var monitoringManager = MonitoringManager.shared
    @ObservedObject private var watchManager = WatchConnectivityManager.shared
    @StateObject private var locationManager = LocationManager()
    
    // Bottom sheet state
    @State private var sheetDetent: PresentationDetent = .height(200)
    @State private var isFormVisible: Bool = false
    
    // Form input
    @State private var namaZona: String = ""
    @State private var selectedZona: JenisZona = .ketat
    
    // Sub-sheet
    @State private var showZonaInfo: Bool = false
    @State private var showPilihZona: Bool = false
    
    // Map
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // Stop monitoring alert
    @State private var showStopAlert: Bool = false
    
    enum ActiveSheet: Identifiable {
        case main
        var id: Int { 0 }
    }
    
    
    var body: some View {
        ZStack(alignment: .top) {
            // MARK: - Map
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                if let lokasi = watchManager.lokasiWatch {
                    Annotation("Lansia", coordinate: lokasi) {
                        ZStack {
                            // Shadow
                            Circle()
                                .fill(Color.black.opacity(0.15))
                                .frame(width: 52, height: 52)
                                .offset(y: 2)
                            
                            // Border putih
                            Circle()
                                .fill(.white)
                                .frame(width: 48, height: 48)
                            
                            // Isi — bisa foto atau inisial
                            Circle()
                                .fill(Color(hex: "#E6F1FB"))
                                .frame(width: 44, height: 44)
                            
                            // Inisial atau ikon lansia
                            Text("👴")
                                .font(.system(size: 26))
                        }
                    }
                }
                
                if let pusat = monitoringManager.pusatZona {
                    MapCircle(center: pusat, radius: monitoringManager.jenisZona.radius)
                        .foregroundStyle(
                            monitoringManager.isKeluarZona
                            ? Color(hex: "#E24B4A").opacity(0.15)
                            : Color(hex: "#185FA5").opacity(0.15)
                        )
                        .stroke(
                            monitoringManager.isKeluarZona
                            ? Color(hex: "#E24B4A")
                            : Color(hex: "#185FA5"),
                            lineWidth: 2
                        )
                }
            }
            .mapStyle(.hybrid)
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .ignoresSafeArea()
            // MARK: - Status Pill
            StatusPillView(isMemantau: monitoringManager.isMemantau)
                .padding(.top, 60)
        }
        
        // MARK: - Bottom Sheet
        .sheet(isPresented: .constant(true)) {
            sheetContent
        }
        
        // ✅ Lokasi Watch masuk → update status zona (sudah ada)
        .onReceive(watchManager.$lokasiWatch) { lokasi in
            guard let lokasi = lokasi else { return }
            monitoringManager.updateStatus(lokasiLansia: lokasi)
            monitoringManager.lastUpdate = Date()
        }
 
        // ✅ Battery Watch → sinkron ke MonitoringManager
        .onReceive(watchManager.$watchBattery) { battery in
            monitoringManager.watchBatteryLevel = battery
        }
 
        // ✅ KONEKSI WATCH → propagate + trigger notif otomatis via MonitoringManager
        .onReceive(watchManager.$isWatchConnected) { connected in
            monitoringManager.updateWatchConnection(connected: connected)
        }
    }
    
    private var sheetContent: some View {
        VStack(spacing: 0) {
            
            // Drag indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 36, height: 4)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            // MARK: - Tab Content
            if selectedTab == 0 {
                pantauContent
            } else {
                RiwayatView()
            }
            
            Spacer(minLength: 0)
            
            // MARK: - Tab Bar
            CustomTabBar(
                selectedTab: $selectedTab,
                onSelectPantau: {
                    withAnimation {
                        selectedTab = 0
                        isFormVisible = false
                        sheetDetent = .height(200)
                    }
                },
                onSelectRiwayat: {
                    withAnimation {
                        selectedTab = 1
                        sheetDetent = .height(340)
                    }
                }
            )
        }
        .presentationDetents(detentsForCurrentState)
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(44)
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled(true)
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
        .alert("Berhenti Memantau?", isPresented: $showStopAlert) {
            Button("Tidak", role: .cancel) {}
            Button("Ya", role: .destructive) {
                monitoringManager.berhentiMemantau()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    monitoringManager.pusatZona = nil
                }
            }
        } message: {
            Text("Pemantauan akan dihentikan.")
        }
    }
    
    // MARK: - Pantau Content
    @ViewBuilder
    private var pantauContent: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Pantau")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            if monitoringManager.isMemantau {
                monitoringStatusView
            } else if isFormVisible {
                FormZonaView(
                    namaZona: $namaZona,
                    selectedZona: $selectedZona,
                    showZonaInfo: $showZonaInfo,
                    showPilihZona: $showPilihZona
                )
            }
            
            Button {
                handleTombolMemantau()
            } label: {
                Text(monitoringManager.isMemantau
                     ? "Berhenti Memantau"
                     : "Mulai Memantau")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        monitoringManager.isMemantau
                        ? Color(hex: "#A32D2D")
                        : Color(hex: "#185FA5")
                    )
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Handle Tombol
    private func handleTombolMemantau() {
        if monitoringManager.isMemantau {
            showStopAlert = true
        } else if !isFormVisible {
            withAnimation(.spring(duration: 0.35)) {
                isFormVisible = true
                sheetDetent = .height(320)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sheetDetent = .height(320)
            }
        } else {
            guard let lokasi = locationManager.lastLocation?.coordinate else { return }
            monitoringManager.namaZona = namaZona
            monitoringManager.jenisZona = selectedZona
            monitoringManager.mulaiMemantau(lokasi: lokasi)
            withAnimation {
                isFormVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sheetDetent = .height(200)
            }
        }
    }
    
    
    // MARK: tampilan pas lagi monitoring
    private var monitoringStatusView: some View {
        VStack(spacing: 16) {
            
            // MARK: - MAIN CARD
            VStack(spacing: 16) {
                
                // HEADER (icon + nama + update + battery)
                HStack(alignment: .top, spacing: 12) {
                    
                    // ICON LOKASI
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#2F80ED").opacity(0.15))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "location.fill")
                            .foregroundColor(Color(hex: "#2F80ED"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text(monitoringManager.namaZona)
                            .font(.headline)
                        
                        Text("Diperbarui \(timeAgo)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // BATTERY
                    batteryView
                }
                
                // MARK: - SUB CARDS (2 kotak sama besar)
                HStack(spacing: 12) {
                    
                    // STATUS ZONA
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 6) {
                            Circle()
                                .fill(monitoringManager.isDalamZona ? .green : .red)
                                .frame(width: 8, height: 8)
                            
                            Text(
                                monitoringManager.isDalamZona
                                ? "Berada di dalam zona aman"
                                : "Keluar dari zona"
                            )
                            .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    // JENIS ZONA
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Jenis Zona")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(monitoringManager.jenisZona.label)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
            }
            .padding()
            .background(.ultraThickMaterial)
            .cornerRadius(24)
        }
        .padding(.horizontal, 20)
    }
    
    //UKURAN SHEET TIAP FITUR
    private var detentsForCurrentState: Set<PresentationDetent> {
        if selectedTab == 1 {
            // RIWAYAT → tetap flexible
            return [.height(340), .large]
            
        } else if monitoringManager.isMemantau {
            // 🔥 MONITORING → FIX (sesuai desain kamu)
            return [.height(380)]
            
        } else if isFormVisible {
            // FORM INPUT
            return [.height(320)]
            
        } else {
            // DEFAULT (button only)
            return [.height(200)]
        }
    }
    
    // MARK: TAMPILAN BATTRENYA
    private var batteryView: some View {
        HStack(spacing: 4) {
            Image(systemName: batteryIconName)
            Text("\(Int(monitoringManager.watchBatteryLevel * 100))%")
                .font(.caption)
        }
        .foregroundColor(batteryColor)
    }
    
    private var batteryIconName: String {
        let level = monitoringManager.watchBatteryLevel
        
        switch level {
        case 0.75...: return "battery.100"
        case 0.5..<0.75: return "battery.75"
        case 0.25..<0.5: return "battery.50"
        case 0.1..<0.25: return "battery.25"
        default: return "battery.0"
        }
    }

    private var batteryColor: Color {
        monitoringManager.watchBatteryLevel < 0.2 ? .red : .primary
    }
    
    private var timeAgo: String {
        let seconds = Int(Date().timeIntervalSince(monitoringManager.lastUpdate))
        return "\(seconds) detik lalu"
    }
}

#Preview {
    PantauView(selectedTab: .constant(0))
}
