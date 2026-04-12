//
//  CustomTabBar.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 12/04/26.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let onSelectPantau: () -> Void
    let onSelectRiwayat: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                tabButton(
                    label: "Pantau",
                    iconActive: "location.fill",
                    iconInactive: "location",
                    index: 0,
                    action: onSelectPantau
                )
                
                tabButton(
                    label: "Riwayat",
                    iconActive: "clock.fill",
                    iconInactive: "clock",
                    index: 1,
                    action: onSelectRiwayat
                )
            }
            .padding(.horizontal, 50)
            .padding(.top, 5)
            .padding(.bottom, 1)
        }
    }
    
    @ViewBuilder
    private func tabButton(
        label: String,
        iconActive: String,
        iconInactive: String,
        index: Int,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == index ? iconActive : iconInactive)
                    .font(.system(size: 26))
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundColor(selectedTab == index
                             ? Color(hex: "#185FA5")
                             : .secondary)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    CustomTabBar(
        selectedTab: .constant(0),
        onSelectPantau: {},
        onSelectRiwayat: {}
    )
}
