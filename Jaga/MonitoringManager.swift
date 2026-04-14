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
    case ketat = "Ketat"
    case sedang = "Sedang"
    case longgar = "Longgar"
    
    var radius: Double {
        switch self {
        case .ketat: return 10
        case .sedang: return 20
        case .longgar: return 30
        }
    }
    
    var label: String {
        switch self {
        case .ketat: return "Ketat (~10m)"
        case .sedang: return "Sedang (~20m)"
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
        case .ketat: return "#85B7EB"
        case .sedang: return "#378ADD"
        case .longgar: return "#185FA5"
        }
    }
    
    var ukuranDot: CGFloat {
        switch self {
        case .ketat: return 10
        case .sedang: return 14
        case .longgar: return 18
        }
    }
    
//    var lokasiLansia: CLLocationCoordinate2D? {
//        return WatchConnectivityManager.shared.lokasiWatch
//    }
}

class MonitoringManager: ObservableObject {
    static let shared = MonitoringManager()
    
    @Published var isMemantau: Bool = false
    @Published var namaZona: String = ""
    @Published var jenisZona: JenisZona = .ketat
    @Published var pusatZona: CLLocationCoordinate2D?
//    @Published var lokasiLansia: CLLocationCoordinate2D?
    @Published var isKeluarZona: Bool = false
    
    func mulaiMemantau(lokasi: CLLocationCoordinate2D) {
        pusatZona = lokasi
        isMemantau = true
    }
    
    func berhentiMemantau() {
        isMemantau = false
        pusatZona = nil
        isKeluarZona = false
    }
}
