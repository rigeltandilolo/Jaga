//
//  OnboardingPageLayout.swift
//  Jaga
//
//  Created by Rigel Sundun Tandilolo on 09/04/26.
//

import SwiftUI

struct OnboardingPageLayout: View {
    var iconName: String
    var isLogo: Bool = false
    var isSFSymbol: Bool = false
    var iconColor: Color = Color(hex: "#185FA5")
    var iconBackgroundColor: Color = Color(hex: "#E6F1FB")
    var title: String
    var titleAccent: String = ""
    var titleSuffix: String = ""
    var accentColor: Color = Color(hex: "#185FA5")
    var description: String
    var buttonLabel: String
    var buttonAction: () -> Void
    var secondaryLabel: String? = nil
    var secondaryAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Icon / Logo
            ZStack {
                Circle()
                        .fill(iconBackgroundColor.opacity(0.3))
                        .frame(width: 210, height: 210)
                    
                    Circle()
                        .fill(iconBackgroundColor.opacity(0.6))
                        .frame(width: 180, height: 180)
                    
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 150, height: 150)
                
                if isLogo {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130)
                } else if isSFSymbol {
                    Image(systemName: iconName)
                        .font(.system(size: 88))
                        .foregroundColor(iconColor)
                }
            }
            .padding(.bottom, 40)
            
            // Title
            Group {
                Text(title)
                    .foregroundColor(.primary) +
                Text(titleAccent)
                    .foregroundColor(accentColor) +
                Text(titleSuffix)
                    .foregroundColor(.primary)
            }
            .font(.title2)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.bottom, 16)
            
            // Description
            Text(description)
                .font(.body)
                .foregroundColor(Color(hex: "#5F5E5A"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Primary Button
            Button(action: buttonAction) {
                Text(buttonLabel)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#185FA5"))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 32)
            .padding(.bottom, secondaryLabel != nil ? 12 : 48)
            
            // Secondary Button (opsional)
            if let label = secondaryLabel, let action = secondaryAction {
                Button(action: action) {
                    Text(label)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#185FA5"))
                }
                .padding(.bottom, 48)
            }
        }
    }
}
