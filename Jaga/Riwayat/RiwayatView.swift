//
//  RiwayatView.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 12/04/26.
//

import SwiftUI

struct RiwayatView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Riwayat")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            
            Spacer()
            
            Text("Belum ada riwayat")
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    RiwayatView()
}
