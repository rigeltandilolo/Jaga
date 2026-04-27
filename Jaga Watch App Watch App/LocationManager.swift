//
//  LocationManager.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 11/04/26.
//

import CoreLocation
import WatchConnectivity
import WatchKit
import Combine

class WatchLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, WKExtendedRuntimeSessionDelegate {
    private let manager = CLLocationManager()
    private let sessionManager = WatchSessionManager.shared
    private var extendedSession: WKExtendedRuntimeSession?
    
    // Ganti Timer → DispatchSourceTimer (lebih reliable di background)
       private var heartbeatTimer: DispatchSourceTimer?
    
    @Published var currentLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 3 // update setiap bergerak 5 meter
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        startExtendedRuntimeSession()
        startHeartbeat()
    }
    
    // MARK: - Heartbeat (kirim sinyal tiap 30 detik meski tidak bergerak)
    private func startHeartbeat() {
        heartbeatTimer?.cancel()

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .background))
        timer.schedule(deadline: .now() + 10, repeating: 10)
        timer.setEventHandler { [weak self] in
            self?.sendHeartbeat()
        }
        timer.resume()
        heartbeatTimer = timer
    }

    private func sendHeartbeat() {
        guard WCSession.isSupported() else { return }

        var payload: [String: Any] = ["heartbeat": true]

        // Sertakan lokasi terakhir jika ada (supaya iPhone tetap punya lokasi terbaru)
        if let loc = currentLocation {
            payload["latitude"]  = loc.coordinate.latitude
            payload["longitude"] = loc.coordinate.longitude
        }

        payload["timestamp"] = Date().timeIntervalSince1970

        do {
            try WCSession.default.updateApplicationContext(payload)
        } catch {
            print("Heartbeat error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Extended Runtime Session
    private func startExtendedRuntimeSession() {
        let session = WKExtendedRuntimeSession()
        session.delegate = self
        session.start() // default akan menggunakan mode Self Care
        extendedSession = session
    }

    // Delegate: session berhasil dimulai
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended runtime session aktif")
    }

    // Delegate: session akan berakhir (kamu punya waktu singkat untuk cleanup/restart)
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session akan expired, coba restart...")
        // Restart session supaya tetap aktif
        startExtendedRuntimeSession()
    }

    // Delegate: session berakhir
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                 didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                 error: Error?) {
        print("Session invalid: \(reason.rawValue), error: \(error?.localizedDescription ?? "-")")
        // Coba restart setelah beberapa detik
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.startExtendedRuntimeSession()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        DispatchQueue.main.async {
            self.currentLocation = location
        }
        
        // Kirim lokasi ke iPhone
        sendLocationToiPhone(location: location)
    }
    
    private func sendLocationToiPhone(location: CLLocation) {
        guard WCSession.isSupported() else { return }
        
        let locationData: [String: Any] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Coba sendMessage dulu (real-time)
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(locationData, replyHandler: { _ in }) { error in
                print("sendMessage error: \(error.localizedDescription)")
            }
        }
        
        // Backup via updateApplicationContext (tidak butuh reachable)
        do {
            try WCSession.default.updateApplicationContext(locationData)
        } catch {
            print("updateApplicationContext error: \(error.localizedDescription)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
