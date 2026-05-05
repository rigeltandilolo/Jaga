//
//  Riwayatdetailview.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 21/04/26.
//

import SwiftUI
import MapKit
 
struct RiwayatDetailView: View {
    let sesi: RiwayatSesi
    @Environment(\.dismiss) private var dismiss
    @State private var showFullMap = false
 
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
 
                    // MARK: - Alert Banner
                    alertBanner
 
                    // MARK: - Informasi Pemantauan
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Informasi Pemantauan")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
 
                        VStack(spacing: 0) {
                            // Kronologi
                            kronologiRow
 
                            Divider().padding(.leading, 16)
 
                            // Nama Zona
                            namaZonaRow
 
                            Divider().padding(.leading, 16)
 
                            // Durasi
                            durasiRow
                        }
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal, 20)
                    }
 
                    // MARK: - Lokasi Terakhir (sneak peek maps)
                    VStack(alignment: .leading, spacing: 12) {
                        Button {
                            showFullMap = true
                        } label: {
                            HStack {
                                Text("Lokasi Kejadian")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 20)
 
                        // Sneak peek peta (tidak interaktif)
                        sneakPeekMap
                            .padding(.horizontal, 20)
                    }
 
                    Spacer(minLength: 32)
                }
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(sesi.namaZona)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showFullMap) {
            RiwayatMapsView(sesi: sesi)
        }
    }
 
    // MARK: - Alert Banner
    @ViewBuilder
    private var alertBanner: some View {
        let (ikon, judul, sub, bg, warnaIkon): (String, String, String, Color, Color) = {
            switch sesi.statusAkhir {
            case .keluarZona:
                let kali = sesi.jumlahKeluarZona
                return (
                    "exclamationmark.triangle.fill",
                    "Keluar dari zona aman",
                    "Terdeteksi keluar dari batas radius aman \(kali > 1 ? "\(kali) kali" : "").",
                    Color(hex: "#FCEBEB"),
                    Color(hex: "#A32D2D")
                )
            case .disconnect:
                return (
                    "exclamationmark.triangle.fill",
                    "Koneksi Watch terputus",
                    "Koneksi watch terputus pada saat sedang memantau.",
                    Color(hex: "#FFF3E0"),
                    Color(hex: "#B85C00")
                )
            case .aman:
                return (
                    "checkmark.circle.fill",
                    "Tetap di dalam zona aman",
                    "Lansia tetap berada di dalam zona aman selama proses pemantauan.",
                    Color(hex: "#E8F8F2"),
                    Color(hex: "#1D9E75")
                )
            }
        }()
 
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: ikon)
                .font(.system(size: 32))
                .foregroundColor(warnaIkon)
 
            VStack(alignment: .leading, spacing: 6) {
                Text(judul)
                    .font(.headline)
                    .foregroundColor(warnaIkon)
                Text(sub)
                    .font(.subheadline)
                    .foregroundColor(warnaIkon.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 20)
    }
 
    // MARK: - Kronologi Timeline
    @ViewBuilder
    private var kronologiRow: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon kiri
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(width: 44, height: 44)
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(Color(hex: "#185FA5"))
            }
 
            VStack(alignment: .leading, spacing: 0) {
                Text("Kronologi Pemantauan")
                    .font(.caption)
                    .foregroundColor(.secondary)
//                    .padding(.top, 12)
                    .padding(.bottom, 8)
 
                // Timeline items
                ForEach(Array(sesi.kejadianTerurut.enumerated()), id: \.element.id) { idx, item in
                    HStack(alignment: .top, spacing: 10) {
                        // Dot + garis
                        VStack(spacing: 0) {
                            Circle()
                                .fill(dotWarna(item.jenis))
                                .frame(width: 10, height: 10)
                                .padding(.top, 3)
                            if idx < sesi.kejadianTerurut.count - 1 {
                                Rectangle()
                                    .fill(Color(.separator))
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: 10)
 
                        VStack(alignment: .leading, spacing: 2) {
                            // Badge label
                            Text(item.jenis.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(dotWarna(item.jenis))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(dotWarna(item.jenis).opacity(0.15))
                                .clipShape(Capsule())
 
                            // Waktu
                            Text(formatWaktu(item.waktu))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 12)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .alignmentGuide(.top) { d in d[.top] } //HStack rata atas
    }
 
    // MARK: - Nama Zona Row
    @ViewBuilder
    private var namaZonaRow: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(width: 44, height: 44)
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(Color(hex: "#185FA5"))
            }
 
            VStack(alignment: .leading, spacing: 4) {
                Text("Nama Zona")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(sesi.namaZona)
                    .font(.body)
                    .fontWeight(.medium)
                if !sesi.alamatZona.isEmpty {
                    Text(sesi.alamatZona)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(16)
    }
 
    // MARK: - Durasi Row
    @ViewBuilder
    private var durasiRow: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(width: 44, height: 44)
                Image(systemName: "timer")
                    .foregroundColor(Color(hex: "#185FA5"))
            }
 
            VStack(alignment: .leading, spacing: 4) {
                Text("Durasi Pemantauan")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(sesi.durasiFormatted)
                    .font(.body)
                    .fontWeight(.medium)
            }
            Spacer()
        }
        .padding(16)
    }
 
    // MARK: - Sneak Peek Map
    @ViewBuilder
    private var sneakPeekMap: some View {
        // Tentukan region berdasarkan titik-titik kejadian
        let region = mapRegion
 
        Map(initialPosition: .region(region)) {
            // Pin zona pusat
            Annotation("Pusat Zona", coordinate: sesi.pusatKoordinat) {
                ZStack {
                    Circle().fill(Color(hex: "#185FA5").opacity(0.2)).frame(width: 32, height: 32)
                    Circle().fill(Color(hex: "#185FA5")).frame(width: 12, height: 12)
                }
            }
 
            // Pin per kejadian
            ForEach(sesi.titikUntukMaps) { item in
                Annotation(item.jenis.rawValue, coordinate: item.koordinat) {
                    pinView(item.jenis)
                }
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .disabled(true) // sneak peek tidak interaktif
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .onTapGesture { showFullMap = true }
    }
 
    // MARK: - Helpers
 
    private var mapRegion: MKCoordinateRegion {
        var coords = sesi.titikUntukMaps.map { $0.koordinat }
        coords.append(sesi.pusatKoordinat)
 
        guard !coords.isEmpty else {
            return MKCoordinateRegion(
                center: sesi.pusatKoordinat,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        }
 
        let lats = coords.map { $0.latitude }
        let lons = coords.map { $0.longitude }
        let minLat = lats.min()!, maxLat = lats.max()!
        let minLon = lons.min()!, maxLon = lons.max()!
 
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.5, 0.003),
            longitudeDelta: max((maxLon - minLon) * 1.5, 0.003)
        )
        return MKCoordinateRegion(center: center, span: span)
    }
 
    private func dotWarna(_ jenis: JenisKejadian) -> Color {
        switch jenis {
        case .mulai, .selesai:     return .secondary
        case .keluarZona:          return Color(hex: "#A32D2D")
        case .kembaliKeZona:       return Color(hex: "#1D9E75")
        case .disconnect:          return Color(hex: "#B85C00")
        case .reconnect:           return Color(hex: "#1D9E75")
        }
    }
 
    @ViewBuilder
    private func pinView(_ jenis: JenisKejadian) -> some View {
        let warna: Color = dotWarna(jenis)
        ZStack {
            Circle().fill(.white).frame(width: 32, height: 32)
                .shadow(radius: 2)
            Circle().fill(warna).frame(width: 22, height: 22)
            Text(pinEmoji(jenis)).font(.system(size: 12))
        }
    }
 
    private func pinEmoji(_ jenis: JenisKejadian) -> String {
        switch jenis {
        case .keluarZona:   return "👴"
        case .disconnect:   return "👴"
        default:            return "👴"
        }
    }
 
    private func formatWaktu(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm, dd MMMM yyyy"
        f.locale = Locale(identifier: "id_ID")
        return f.string(from: date)
    }
}
 
// MARK: - Full Screen Maps View
struct RiwayatMapsView: View {
    let sesi: RiwayatSesi
    @Environment(\.dismiss) private var dismiss
 
    var body: some View {
        NavigationStack {
            Map {
                // Lingkaran zona aman
                MapCircle(center: sesi.pusatKoordinat, radius: sesi.zonaRadius)
                    .foregroundStyle(Color(hex: "#185FA5").opacity(0.12))
                    .stroke(Color(hex: "#185FA5"), lineWidth: 2)
 
                // Pin pusat zona
                Annotation("Pusat Zona", coordinate: sesi.pusatKoordinat) {
                    ZStack {
                        Circle().fill(Color(hex: "#185FA5").opacity(0.2)).frame(width: 36, height: 36)
                        Circle().fill(Color(hex: "#185FA5")).frame(width: 14, height: 14)
                    }
                }
 
                // Pin tiap kejadian dengan warna berbeda
                ForEach(sesi.titikUntukMaps) { item in
                    Annotation(item.jenis.rawValue, coordinate: item.koordinat) {
                        fullPinView(item)
                    }
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Lokasi Kejadian")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                legendView
            }
        }
    }
 
    @ViewBuilder
    private func fullPinView(_ item: KejadianItem) -> some View {
        let warna = pinWarna(item.jenis)
        ZStack {
            Circle().fill(.white).frame(width: 40, height: 40).shadow(radius: 3)
            Circle().fill(warna).frame(width: 28, height: 28)
            Text("👴").font(.system(size: 14))
        }
    }
 
    private func pinWarna(_ jenis: JenisKejadian) -> Color {
        switch jenis {
        case .keluarZona:  return Color(hex: "#A32D2D")
        case .disconnect:  return Color(hex: "#B85C00")
        default:           return Color(hex: "#1D9E75")
        }
    }
 
    // Legend di bawah maps
    @ViewBuilder
    private var legendView: some View {
        let adaKeluarZona  = sesi.titikUntukMaps.contains { $0.jenis == .keluarZona }
        let adaDisconnect  = sesi.titikUntukMaps.contains { $0.jenis == .disconnect }
 
        if adaKeluarZona || adaDisconnect {
            HStack(spacing: 20) {
                if adaKeluarZona {
                    legendItem(warna: Color(hex: "#A32D2D"), label: "Keluar zona")
                }
                if adaDisconnect {
                    legendItem(warna: Color(hex: "#B85C00"), label: "Watch terputus")
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
        }
    }
 
    @ViewBuilder
    private func legendItem(warna: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(warna).frame(width: 10, height: 10)
            Text(label).font(.caption).foregroundColor(.primary)
        }
    }
}
