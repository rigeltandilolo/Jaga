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
    @StateObject private var watchManager = WatchConnectivityManager.shared
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
            .presentationDetents(
                selectedTab == 1 ? [.height(340), .large] : (isFormVisible ? [.height(320)] : [.height(200)]),
                selection: $sheetDetent
            )
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(44)
            .presentationBackgroundInteraction(.enabled(upThrough: .large))
            .interactiveDismissDisabled(true)
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
        }
        .alert("Berhenti Memantau?", isPresented: $showStopAlert) {
            Button("Tidak", role: .cancel) {}
            Button("Ya", role: .destructive) {
                monitoringManager.berhentiMemantau()
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
            
            if isFormVisible {
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
}

#Preview {
    PantauView(selectedTab: .constant(0))
}

