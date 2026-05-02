//
//  StatusPillView.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 12/04/26.
//

import SwiftUI

struct StatusPillView: View {
    let isMemantau: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(isMemantau
                      ? Color(hex: "#1D9E75")
                      : Color(hex: "#888780"))
                .frame(width: 16, height: 16)
            Text(isMemantau
                 ? "Sedang memantau"
                 : "Sedang tidak memantau")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

#Preview {
    StatusPillView(isMemantau: false)
}
