//
//  NotificationManager.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 19/04/26.
//

import Foundation
import UserNotifications
 
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
 
    // MARK: - Notification Identifiers
    private let idKeluarZona      = "jaga.keluar_zona"
    private let idWatchDisconnect = "jaga.watch_disconnect"
 
    // MARK: - Cooldown agar notif tidak spam
    private var lastKeluarZonaNotif: Date?
    private var lastWatchDisconnectNotif: Date?
    private let cooldownDetik: TimeInterval = 30 // minimal detik antar notif sejenis
 
    // MARK: - Init
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
 
    // MARK: - Minta izin notifikasi (panggil dari JagaApp saat launch)
    func mintaIzinNotifikasi() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("❌ Notifikasi error: \(error.localizedDescription)")
            } else {
                print(granted ? "✅ Izin notifikasi diberikan" : "⚠️ Izin notifikasi ditolak")
            }
        }
    }
 
    // MARK: - Notifikasi: Lansia Keluar Zona Aman 🔴
    func kirimNotifKeluarZona(namaZona: String) {
        // Cek cooldown
        if let last = lastKeluarZonaNotif,
           Date().timeIntervalSince(last) < cooldownDetik { return }
        lastKeluarZonaNotif = Date()
 
        let content = UNMutableNotificationContent()
        content.title = "🔴 \(namaZona.uppercased()) KELUAR ZONA AMAN"
        content.body  = "\(namaZona) terdeteksi keluar dari zona aman! Cepat cegat sebelum tambah jauh cuy??"
        content.sound = .defaultCritical  // suara lebih mencolok
        content.interruptionLevel = .critical // muncul bahkan saat Do Not Disturb (iOS 15+)
 
        kirimNotifikasi(id: idKeluarZona, content: content)
    }
 
    // MARK: - Notifikasi: Apple Watch Tidak Terdeteksi 🟡
    func kirimNotifWatchDisconnect(namaLansia: String = "Oma Uci") {
        // Cek cooldown
        if let last = lastWatchDisconnectNotif,
           Date().timeIntervalSince(last) < cooldownDetik { return }
        lastWatchDisconnectNotif = Date()
 
        let content = UNMutableNotificationContent()
        content.title = "🟡 \(namaLansia.uppercased()) TIDAK TERDETEKSI"
        content.body  = "Watch yang digunakan \(namaLansia.lowercased()) tidak terhubung pada jaringan ataupun iPhone, segera periksa!"
        content.sound = .default
        content.interruptionLevel = .timeSensitive // muncul meski HP di-silent
 
        kirimNotifikasi(id: idWatchDisconnect, content: content)
    }
 
    // MARK: - Reset cooldown (dipanggil saat monitoring dihentikan)
    func resetCooldown() {
        lastKeluarZonaNotif = nil
        lastWatchDisconnectNotif = nil
    }
 
    // MARK: - Helper private
    private func kirimNotifikasi(id: String, content: UNMutableNotificationContent) {
        // Hapus notifikasi lama dengan ID yang sama dulu
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
 
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
 
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Gagal kirim notifikasi [\(id)]: \(error.localizedDescription)")
            } else {
                print("🔔 Notifikasi terkirim: \(id)")
            }
        }
    }
 
    // MARK: - UNUserNotificationCenterDelegate
    // Agar notif tetap muncul meski app sedang di foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
