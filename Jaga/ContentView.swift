//
//  ContentView.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 08/04/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            // Map selalu di belakang
            PantauView(selectedTab: $selectedTab)
        }
    }
}

#Preview {
    ContentView()
}
