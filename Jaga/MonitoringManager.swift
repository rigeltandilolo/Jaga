//
//  MonitoringManager.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 11/04/26.
//

import Foundation
import CoreLocation
import Combine
 
enum JenisZona: String, CaseIterable {
    case ketat   = "Ketat"
    case sedang  = "Sedang"
    case longgar = "Longgar"
 
    var radius: Double {
        switch self {
        case .ketat:   return 10
        case .sedang:  return 20
        case .longgar: return 30
        }
    }
 
    var label: String {
        switch self {
        case .ketat:   return "Ketat (~10m)"
        case .sedang:  return "Sedang (~20m)"
        case .longgar: return "Longgar (~30m)"
        }
    }
 
    var deskripsi: String {
        switch self {
        case .ketat:
            return "Cocok untuk lansia yang membutuhkan pengawasan intensif. Peringatan akan diberikan ketika lansia bergerak melewati batas area yang sangat dekat, seperti keluar dari ruangan atau mendekati pintu keluar rumah."
        case .sedang:
            return "Cocok untuk pengawasan sehari-hari. Lansia masih dapat bergerak di dalam rumah dan area sekitarnya, namun peringatan akan diberikan jika lansia mulai menjauh ke luar area rumah."
        case .longgar:
            return "Cocok untuk lansia yang masih cukup mandiri. Lansia dapat bergerak lebih leluasa di sekitar rumah dan halaman, namun tetap terpantau jika bergerak terlalu jauh dari titik aman."
        }
    }
 
    var warnaDot: String {
        switch self {
        case .ketat:   return "#85B7EB"
        case .sedang:  return "#378ADD"
        case .longgar: return "#185FA5"
        }
    }
 
    var ukuranDot: CGFloat {
        switch self {
        case .ketat:   return 10
        case .sedang:  return 14
        case .longgar: return 18
        }
    }
}
 
class MonitoringManager: ObservableObject {
    static let shared = MonitoringManager()
 
    @Published var isMemantau: Bool       = false
    @Published var namaZona: String       = ""
    @Published var jenisZona: JenisZona   = .ketat
    @Published var pusatZona: CLLocationCoordinate2D?
    @Published var isKeluarZona: Bool     = false
    @Published var jarakDariPusat: Double = 0
    @Published var isDalamZona: Bool      = true
 
    @Published var watchBatteryLevel: Float = 0
    @Published var isWatchConnected: Bool   = false
 
    @Published var lastUpdate: Date = Date()
 
    // Lacak state sebelumnya untuk trigger notif hanya sekali per event
    private var wasKeluarZona: Bool    = false
    private var wasWatchConnected: Bool = true
 
    // MARK: - Mulai Memantau
    func mulaiMemantau(lokasi: CLLocationCoordinate2D) {
        pusatZona      = lokasi
        isMemantau     = true
        wasKeluarZona  = false
        wasWatchConnected = true
        NotificationManager.shared.resetCooldown()
    }
 
    // MARK: - Berhenti Memantau
    func berhentiMemantau() {
        isMemantau    = false
        isKeluarZona  = false
        isDalamZona   = true
        wasKeluarZona = false
        NotificationManager.shared.resetCooldown()
    }
 
    // MARK: - Update posisi lansia dari Watch
    func updateStatus(lokasiLansia: CLLocationCoordinate2D) {
        guard let pusat = pusatZona, isMemantau else { return }
 
        let center = CLLocation(latitude: pusat.latitude, longitude: pusat.longitude)
        let lansia = CLLocation(latitude: lokasiLansia.latitude, longitude: lokasiLansia.longitude)
        let distance = center.distance(from: lansia)
 
        jarakDariPusat = distance
 
        let keluarSekarang = distance > jenisZona.radius
        isKeluarZona = keluarSekarang
        isDalamZona  = !keluarSekarang
 
        // ✅ Kirim notif KELUAR ZONA hanya saat baru saja keluar (bukan terus-menerus)
        if keluarSekarang && !wasKeluarZona {
            let nama = namaZona.isEmpty ? "Lansia" : namaZona
            NotificationManager.shared.kirimNotifKeluarZona(namaZona: nama)
        }
        wasKeluarZona = keluarSekarang
    }
 
    // MARK: - Update status koneksi Watch
    func updateWatchConnection(connected: Bool) {
        isWatchConnected = connected
 
        // ✅ Kirim notif WATCH DISCONNECT hanya saat baru saja terputus
        if !connected && wasWatchConnected && isMemantau {
            let nama = namaZona.isEmpty ? "Oma Uci" : namaZona
            NotificationManager.shared.kirimNotifWatchDisconnect(namaLansia: nama)
        }
        wasWatchConnected = connected
    }
}
