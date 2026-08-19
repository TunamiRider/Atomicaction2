//
//  AppTheme.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/21/26.
//

import SwiftUI

enum AppTheme {
    
    // Helper to create a dynamic light/dark SwiftUI Color
    private static func dynamicColor(light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
    
    // Dynamic Text Colors
    static var textPrimary: Color {
        dynamicColor(
            light: Color(white: 0.95),  // Bright white/off-white for dark light-mode background
            dark: Color(white: 1.0)     // Pure white for dark mode
        )
    }
    
    static var textSecondary: Color {
        dynamicColor(
            light: Color(white: 0.80),  // Light muted gray for dark teal background
            dark: Color(white: 0.70)    // Slightly darker muted gray for dark mode
        )
    }
    
    static var backgroundGradient: LinearGradient {
            LinearGradient(
                colors: [
                    // Top Color (Dark Forest Teal)
                    dynamicColor(
                        light: Color(red: 0.05, green: 0.22, blue: 0.25),
                        dark: Color(red: 0.18, green: 0.08, blue: 0.24) // Deep Eggplant/Plum
                    ),
                    // Second Color (Rich Dark Teal)
                    dynamicColor(
                        light: Color(red: 0.08, green: 0.28, blue: 0.31),
                        dark: Color(red: 0.24, green: 0.12, blue: 0.32)
                    ),
                    // Third Color (Deep Spruce Teal)
                    dynamicColor(
                        light: Color(red: 0.12, green: 0.35, blue: 0.38),
                        dark: Color(red: 0.32, green: 0.16, blue: 0.42)
                    ),
                    // Bottom Color (Muted Dark Teal Base)
                    dynamicColor(
                        light: Color(red: 0.18, green: 0.42, blue: 0.45),
                        dark: Color(red: 0.40, green: 0.20, blue: 0.50)
                    )
                ],
                startPoint: .top,
                endPoint: .bottom
            )
    }
    
    static var strokeForProgressArc: Color {
        dynamicColor(
                    light: Color(red: 0.35, green: 0.88, blue: 0.82), // Glowing Seafoam Teal
                    dark: Color(red: 0.82, green: 0.55, blue: 0.98)   // Vibrant Lavender/Violet
                )
    }
    static var strokeShadowForProgressArc: Color {
        dynamicColor(
                    light: Color(red: 0.35, green: 0.88, blue: 0.82).opacity(0.4),
                    dark: Color(red: 0.82, green: 0.55, blue: 0.98).opacity(0.4)
                )
    }
    
    static let defaultIconTint = LinearGradient(
        colors: [
            Color(red: 0.98, green: 0.98, blue: 0.99),   // Crisp White / Platinum
            Color(red: 0.88, green: 0.89, blue: 0.91),   // Bright Silver
            Color(red: 0.75, green: 0.77, blue: 0.80),   // Mid Metallic Silver
            Color(red: 0.90, green: 0.91, blue: 0.93)    // Reflective Silver Highlight
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
