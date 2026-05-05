//
//  SplashScreenView.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 09/04/26.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    Image("SplashScreen")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400)
                }
                
                Spacer()

                Text("Selalu dekat, selalu terjaga.")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "#000000"))
                    .padding(.bottom, 78)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
