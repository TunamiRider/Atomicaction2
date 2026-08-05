//
//  AppButtonModifier.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/24/26.
//

import SwiftUI
struct AppButtonModifiler: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .regular))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(Color.black.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                // Glossy static sheen
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .allowsHitTesting(false)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
                    .allowsHitTesting(false) 
            )
            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
        
    }
}
