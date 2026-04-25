//
//  WatchConnectivityManager.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 09/04/26.
//

import WatchConnectivity
import Combine
import CoreLocation
 
class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
 
    @Published var isWatchConnected: Bool          = false
    @Published var lokasiWatch: CLLocationCoordinate2D?
    @Published var watchBattery: Float             = 0
 
    // Timer untuk deteksi timeout (Watch tidak kirim data dalam X detik)
    private var timeoutTimer: Timer?
    private var lastReceivedDate: Date?
    private let timeoutInterval: TimeInterval = 90 // 90 detik tanpa data = disconnect
 
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
 
    // MARK: - Public: cek koneksi manual (dipakai OnboardingView)
    func checkWatchConnection() {
        let connected = WCSession.default.activationState == .activated
            && WCSession.default.isWatchAppInstalled
        updateConnectionStatus(connected)
    }
 
    // MARK: - WCSessionDelegate
 
    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {
        DispatchQueue.main.async {
            let connected = session.activationState == .activated && session.isWatchAppInstalled
            self.updateConnectionStatus(connected)
        }
    }
 
    // ✅ Dipanggil iOS otomatis setiap kali reachability Watch berubah
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            let connected = session.isReachable
            self.updateConnectionStatus(connected)
        }
    }
 
    func sessionDidBecomeInactive(_ session: WCSession) {}
 
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
 
    // MARK: - Terima lokasi dari Watch (real-time)
    func session(_ session: WCSession,
                 didReceiveMessage message: [String: Any]) {
        guard let lat = message["latitude"]  as? Double,
              let lon = message["longitude"] as? Double else { return }
 
        if let battery = message["battery"] as? Float {
            DispatchQueue.main.async { self.watchBattery = battery }
        }
 
        DispatchQueue.main.async {
            self.lokasiWatch = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            self.updateConnectionStatus(true)
            self.resetTimeoutTimer()
        }
    }
 
    // MARK: - Terima lokasi dari Watch (background/context, layar mati)
    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String: Any]) {

        // Update lokasi hanya kalau ada koordinat (bukan pure heartbeat)
        if let lat = applicationContext["latitude"] as? Double,
           let lon = applicationContext["longitude"] as? Double {
            DispatchQueue.main.async {
                self.lokasiWatch = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        }

        // Heartbeat atau lokasi = Watch masih terhubung
        DispatchQueue.main.async {
            self.handleDataReceived()
        }
    }
 
    // MARK: - Timer Timeout
    // Jika 30 detik tidak ada data dari Watch → anggap disconnect
    private func resetTimeoutTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeoutInterval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if !WCSession.default.isReachable {
                    self.updateConnectionStatus(false)
                }
            }
        }
    }
    
    // MARK: - Dipanggil setiap kali data lokasi diterima (dari jalur manapun)
    private func handleDataReceived() {
        lastReceivedDate = Date()
        updateConnectionStatus(true)
        resetTimeoutTimer()
    }
 
    // MARK: - Helper: update status + propagate ke MonitoringManager
    private func updateConnectionStatus(_ connected: Bool) {
        guard isWatchConnected != connected else { return } // skip jika tidak berubah
        isWatchConnected = connected
        MonitoringManager.shared.updateWatchConnection(connected: connected)
    }
}
