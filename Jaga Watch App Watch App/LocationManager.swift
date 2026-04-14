//
//  LocationManager.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 11/04/26.
//

import CoreLocation
import WatchConnectivity
import Combine

class WatchLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let sessionManager = WatchSessionManager.shared
    
    @Published var currentLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 3 // update setiap bergerak 5 meter
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
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
