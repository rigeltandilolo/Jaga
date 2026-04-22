//
//  Riwayatmodel.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 21/04/26.
//

import Foundation
import SwiftData
import CoreLocation
 
// MARK: - Jenis Kejadian dalam kronologi
enum JenisKejadian: String, Codable {
    case mulai          = "Mulai memantau"
    case keluarZona     = "Keluar dari zona aman"
    case kembaliKeZona  = "Kembali ke zona aman"
    case disconnect     = "Koneksi watch terputus"
    case reconnect      = "Koneksi watch kembali"
    case selesai        = "Berhenti memantau"
}
 
// MARK: - Status akhir sesi
enum StatusSesi: String, Codable {
    case aman       = "Di dalam zona aman"
    case keluarZona = "Keluar dari zona aman"
    case disconnect = "Koneksi watch terputus"
}
 
// MARK: - KejadianItem (child)
@Model
class KejadianItem {
    var id: UUID
    var waktu: Date
    var jenisRaw: String        // simpan sebagai String karena SwiftData belum support enum langsung
    var latitude: Double
    var longitude: Double
 
    // Relasi balik ke sesi induk
    var sesi: RiwayatSesi?
 
    init(
        waktu: Date = Date(),
        jenis: JenisKejadian,
        koordinat: CLLocationCoordinate2D
    ) {
        self.id         = UUID()
        self.waktu      = waktu
        self.jenisRaw   = jenis.rawValue
        self.latitude   = koordinat.latitude
        self.longitude  = koordinat.longitude
    }
 
    var jenis: JenisKejadian {
        JenisKejadian(rawValue: jenisRaw) ?? .mulai
    }
 
    var koordinat: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
 
    // Warna dot di timeline & maps
    var warna: String {
        switch jenis {
        case .mulai, .selesai:      return "abu"
        case .keluarZona:           return "merah"
        case .kembaliKeZona:        return "hijau"
        case .disconnect:           return "oranye"
        case .reconnect:            return "hijau"
        }
    }
}
 
// MARK: - RiwayatSesi (parent)
@Model
class RiwayatSesi {
    var id: UUID
    var namaZona: String
    var alamatZona: String          // hasil reverse geocoding
    var jenisZonaRaw: String        // simpan label zona
    var pusatLatitude: Double
    var pusatLongitude: Double
    var zonaRadius: Double
    var waktuMulai: Date
    var waktuSelesai: Date?
    var statusAkhirRaw: String
    var jumlahKeluarZona: Int
    var pernahDisconnect: Bool
 
    // Relasi one-to-many ke KejadianItem
    @Relationship(deleteRule: .cascade, inverse: \KejadianItem.sesi)
    var kejadian: [KejadianItem] = []
 
    init(
        namaZona: String,
        jenisZonaLabel: String,
        pusatKoordinat: CLLocationCoordinate2D,
        zonaRadius: Double
    ) {
        self.id              = UUID()
        self.namaZona        = namaZona
        self.alamatZona      = ""   // diisi setelah reverse geocoding selesai
        self.jenisZonaRaw    = jenisZonaLabel
        self.pusatLatitude   = pusatKoordinat.latitude
        self.pusatLongitude  = pusatKoordinat.longitude
        self.zonaRadius      = zonaRadius
        self.waktuMulai      = Date()
        self.waktuSelesai    = nil
        self.statusAkhirRaw  = StatusSesi.aman.rawValue
        self.jumlahKeluarZona = 0
        self.pernahDisconnect = false
    }
 
    var statusAkhir: StatusSesi {
        get { StatusSesi(rawValue: statusAkhirRaw) ?? .aman }
        set { statusAkhirRaw = newValue.rawValue }
    }
 
    var pusatKoordinat: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: pusatLatitude, longitude: pusatLongitude)
    }
 
    // Kejadian diurutkan berdasarkan waktu
    var kejadianTerurut: [KejadianItem] {
        kejadian.sorted { $0.waktu < $1.waktu }
    }
 
    // Durasi sesi
    var durasi: TimeInterval {
        guard let selesai = waktuSelesai else {
            return Date().timeIntervalSince(waktuMulai)
        }
        return selesai.timeIntervalSince(waktuMulai)
    }
 
    var durasiFormatted: String {
        let total = Int(durasi)
        let jam   = total / 3600
        let menit = (total % 3600) / 60
        if jam > 0 { return "\(jam) jam \(menit) menit" }
        return "\(menit) menit"
    }
 
    // Semua titik kejadian yang punya koordinat valid untuk pin maps
    var titikUntukMaps: [KejadianItem] {
        kejadianTerurut.filter { item in
            item.jenis != .mulai && item.jenis != .selesai &&
            item.jenis != .kembaliKeZona && item.jenis != .reconnect
        }
    }
}
