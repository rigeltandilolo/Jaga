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
    
    @Published var isWatchConnected: Bool = false
    @Published var lokasiWatch: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func checkWatchConnection() {
        isWatchConnected = WCSession.default.isWatchAppInstalled
    }
    
    // MARK: - WCSessionDelegate
    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) {
        DispatchQueue.main.async {
            self.isWatchConnected = session.isWatchAppInstalled
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    
    // Tambahkan delegate method ini
    func session(_ session: WCSession,
                 didReceiveMessage message: [String: Any]) {
        guard let lat = message["latitude"] as? Double,
              let lon = message["longitude"] as? Double else { return }
        
        DispatchQueue.main.async {
            self.lokasiWatch = CLLocationCoordinate2D(
                latitude: lat,
                longitude: lon
            )
        }
    }
    
    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let lat = applicationContext["latitude"] as? Double,
              let lon = applicationContext["longitude"] as? Double else { return }
        
        DispatchQueue.main.async {
            self.lokasiWatch = CLLocationCoordinate2D(
                latitude: lat,
                longitude: lon
            )
        }
    }
}
