//
//  JagaApp.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 08/04/26.
//

import SwiftUI

@main
struct JagaApp: App {
    @State private var showSplash = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else if !hasCompletedOnboarding {
                OnboardingView()
            } else {
                ContentView() // Dashboard utama
            }
        }
    }
}
