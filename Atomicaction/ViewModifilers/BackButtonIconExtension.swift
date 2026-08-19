//
//  BackButtonIconExtension.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 8/11/26.
//
import SwiftUI

extension Image {
    
    
    func circularIconStyle<S: ShapeStyle>(
        size: CGFloat = 28,
        fontSize: CGFloat = 16,
        foregroundColor: Color = .white,
        backgroundStyle: S = AppTheme.backgroundGradient
    ) -> some View {
        self
            .renderingMode(.template)
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundStyle(foregroundColor)
            .frame(width: size, height: size)
            .background(backgroundStyle)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
    }
}
                        
