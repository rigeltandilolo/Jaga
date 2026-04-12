//
//  OnboardingView.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 09/04/26.
//

import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var watchManager = WatchConnectivityManager.shared
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(hex: "#F2F2F7").ignoresSafeArea()
            
            switch currentPage {
            case 0:
                OnboardingWelcomePage {
                    currentPage = 1
                }
            case 1:
                OnboardingLocationPage(locationManager: locationManager) {
                    currentPage = 2
                }
            case 2:
                OnboardingInstallWatchPage {
                    currentPage = 3
                }
            case 3:
                if watchManager.isWatchConnected {
                    OnboardingWatchDetectedPage {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    }
                } else {
                    OnboardingWatchNotDetectedPage {
                        watchManager.checkWatchConnection()
                    }
                }
            default:
                EmptyView()
            }
        }
        .onAppear {
            watchManager.checkWatchConnection()
        }
    }
}

// MARK: - Page 1: Welcome
struct OnboardingWelcomePage: View {
    var onNext: () -> Void
    
    var body: some View {
        OnboardingPageLayout(
            iconName: "LogoJaga",
            isLogo: true,
            title: "Selamat Datang di ",
            titleAccent: "Jaga",
            titleSuffix: "!",
            description: "Aplikasi pemantau lansia yang membantu kamu menjaga orang tersayang tetap aman.",
            buttonLabel: "Mulai Atur Sekarang",
            buttonAction: onNext
        )
    }
}

// MARK: - Page 2: Location
struct OnboardingLocationPage: View {
    @ObservedObject var locationManager: LocationManager
    var onNext: () -> Void
    
    var body: some View {
        OnboardingPageLayout(
            iconName: "location.circle.fill",
            isSFSymbol: true,
            title: "Izinkan Akses ",
            titleAccent: "Lokasi",
            description: "Aplikasi membutuhkan akses lokasi untuk menentukan titik pusat zona aman secara otomatis.",
            buttonLabel: "Izinkan Akses Lokasi",
            buttonAction: {
                locationManager.requestPermission()
            },
            secondaryLabel: "Lewati untuk nanti",
            secondaryAction: onNext
        )
        .onChange(of: locationManager.authorizationStatus) { oldStatus, newStatus in
            if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                onNext()
            }
        }
    }
}

// MARK: - Page 3: Install Watch App
struct OnboardingInstallWatchPage: View {
    var onNext: () -> Void

    var body: some View {
        OnboardingPageLayout(
            iconName: "JagaWatchLogo",
            isLogo: true,
            title: "Unduh Aplikasi ",
            titleAccent: "Jaga",
            titleSuffix: "\nPada Apple Watch Kamu",
            description: "Buka aplikasi Watch untuk mengunduh aplikasi Jaga pada Apple Watch kamu.",
            buttonLabel: "Buka Aplikasi Watch",
            buttonAction: {
                if let url = URL(string: "itms-watchs://") {
                    UIApplication.shared.open(url)
                }
            },
            secondaryLabel: "Sudah Mengunduh",
            secondaryAction: onNext
        )
    }
}

// MARK: - Page 4a: Watch Detected
struct OnboardingWatchDetectedPage: View {
    var onFinish: () -> Void
    
    var body: some View {
        OnboardingPageLayout(
            iconName: "applewatch.radiowaves.left.and.right",
            isSFSymbol: true,
            iconColor: Color(hex: "#185FA5"),
            iconBackgroundColor: Color(hex: "#E6F1FB"),
            title: "Apple Watch ",
            titleAccent: "Terdeteksi",
            description: "Apple Watch kamu terdeteksi dan siap digunakan.",
            buttonLabel: "Mulai ke Jaga",
            buttonAction: onFinish
        )
    }
}

// MARK: - Page 4b: Watch Not Detected
struct OnboardingWatchNotDetectedPage: View {
    var onRetry: () -> Void
    
    var body: some View {
        OnboardingPageLayout(
            iconName: "applewatch.radiowaves.left.and.right",
            isSFSymbol: true,
            iconColor: Color(hex: "#A32D2D"),
            iconBackgroundColor: Color(hex: "#FCEBEB"),
            title: "Apple Watch Tidak ",
            titleAccent: "Terdeteksi",
            accentColor: Color(hex: "#A32D2D"),
            description: "Pastikan Apple Watch kamu sudah terhubung dengan iPhone ini.\n\nSilahkan cek pada aplikasi Watch.",
            buttonLabel: "Buka Aplikasi Watch",
            buttonAction: {
                if let url = URL(string: "itms-watchs://") {
                    UIApplication.shared.open(url)
                }
            },
            secondaryLabel: "Coba Lagi",
            secondaryAction: onRetry
        )
    }
}

#Preview {
    OnboardingView()
}
