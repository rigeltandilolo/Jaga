//
//  Riwayatmanager.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 21/04/26.
//

import Foundation
import SwiftData
import CoreLocation
 
@MainActor
class RiwayatManager {
    static let shared = RiwayatManager()
 
    // ModelContext diinject dari luar (dari App level)
    var modelContext: ModelContext?
 
    private var sesiAktif: RiwayatSesi?
    private let geocoder = CLGeocoder()
 
    // MARK: - Mulai sesi baru
    func mulaiSesi(
        namaZona: String,
        jenisZonaLabel: String,
        pusatKoordinat: CLLocationCoordinate2D,
        zonaRadius: Double,
        lokasiAwal: CLLocationCoordinate2D
    ) {
        guard let ctx = modelContext else { return }
 
        let sesi = RiwayatSesi(
            namaZona: namaZona.isEmpty ? "Zona Tanpa Nama" : namaZona,
            jenisZonaLabel: jenisZonaLabel,
            pusatKoordinat: pusatKoordinat,
            zonaRadius: zonaRadius
        )
 
        // Kejadian pertama: Mulai memantau
        let kejadianMulai = KejadianItem(
            waktu: Date(),
            jenis: .mulai,
            koordinat: lokasiAwal
        )
        sesi.kejadian.append(kejadianMulai)
 
        ctx.insert(sesi)
        sesiAktif = sesi
 
        // Reverse geocoding alamat zona (async, tidak blocking)
        reverseGeocode(koordinat: pusatKoordinat) { alamat in
            sesi.alamatZona = alamat
            try? ctx.save()
        }
 
        try? ctx.save()
    }
 
    // MARK: - Catat kejadian keluar zona
    func catatKeluarZona(koordinat: CLLocationCoordinate2D) {
        guard let sesi = sesiAktif, let ctx = modelContext else { return }
 
        sesi.jumlahKeluarZona += 1
        sesi.statusAkhirRaw = StatusSesi.keluarZona.rawValue
 
        let item = KejadianItem(jenis: .keluarZona, koordinat: koordinat)
        sesi.kejadian.append(item)
        try? ctx.save()
    }
 
    // MARK: - Catat kejadian kembali ke zona
    func catatKembaliKeZona(koordinat: CLLocationCoordinate2D) {
        guard let sesi = sesiAktif, let ctx = modelContext else { return }
 
        let item = KejadianItem(jenis: .kembaliKeZona, koordinat: koordinat)
        sesi.kejadian.append(item)
        try? ctx.save()
    }
 
    // MARK: - Catat watch disconnect
    func catatDisconnect(koordinatTerakhir: CLLocationCoordinate2D?) {
        guard let sesi = sesiAktif, let ctx = modelContext else { return }
 
        // Hanya set status disconnect jika belum pernah keluar zona
        // (prioritas: keluarZona > disconnect)
        sesi.pernahDisconnect = true
        if sesi.statusAkhirRaw == StatusSesi.aman.rawValue {
            sesi.statusAkhirRaw = StatusSesi.disconnect.rawValue
        }
 
        let koordinat = koordinatTerakhir ?? CLLocationCoordinate2D(
            latitude: sesi.pusatLatitude,
            longitude: sesi.pusatLongitude
        )
        let item = KejadianItem(jenis: .disconnect, koordinat: koordinat)
        sesi.kejadian.append(item)
        try? ctx.save()
    }
 
    // MARK: - Catat watch reconnect
    func catatReconnect(koordinat: CLLocationCoordinate2D) {
        guard let sesi = sesiAktif, let ctx = modelContext else { return }
 
        let item = KejadianItem(jenis: .reconnect, koordinat: koordinat)
        sesi.kejadian.append(item)
        try? ctx.save()
    }
 
    // MARK: - Selesaikan sesi
    func selesaiSesi(lokasiAkhir: CLLocationCoordinate2D?) {
        guard let sesi = sesiAktif, let ctx = modelContext else { return }
 
        sesi.waktuSelesai = Date()
 
        let koordinat = lokasiAkhir ?? CLLocationCoordinate2D(
            latitude: sesi.pusatLatitude,
            longitude: sesi.pusatLongitude
        )
        let item = KejadianItem(jenis: .selesai, koordinat: koordinat)
        sesi.kejadian.append(item)
 
        try? ctx.save()
        sesiAktif = nil
    }
 
    // MARK: - Reverse Geocoding
    private func reverseGeocode(
        koordinat: CLLocationCoordinate2D,
        completion: @escaping (String) -> Void
    ) {
        let location = CLLocation(latitude: koordinat.latitude, longitude: koordinat.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            guard let placemark = placemarks?.first else {
                completion("Lokasi tidak diketahui")
                return
            }
            // Format: "Jl. Nama Jalan, Kecamatan"
            let jalan     = placemark.thoroughfare ?? ""
            let kecamatan = placemark.subLocality ?? placemark.locality ?? ""
            let hasil     = [jalan, kecamatan].filter { !$0.isEmpty }.joined(separator: ", ")
            completion(hasil.isEmpty ? "Lokasi tidak diketahui" : hasil)
        }
    }
}
