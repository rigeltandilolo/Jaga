//
//  JagaApp.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 08/04/26.
//

import SwiftUI
import SwiftData
 
@main
struct JagaApp: App {
    @State private var showSplash = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
 
    // SwiftData container — daftarkan semua model di sini
    let container: ModelContainer = {
        let schema = Schema([RiwayatSesi.self, KejadianItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("SwiftData container gagal dibuat: \(error)")
        }
    }()
 
    init() {
        NotificationManager.shared.mintaIzinNotifikasi()
    }
 
    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreenView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation { showSplash = false }
                            }
                        }
                } else if !hasCompletedOnboarding {
                    OnboardingView()
                } else {
                    ContentView()
                }
            }
            // Inject modelContext ke RiwayatManager saat app pertama kali muncul
            .onAppear {
                RiwayatManager.shared.modelContext = container.mainContext
            }
        }
        .modelContainer(container)
    }
}
