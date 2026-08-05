//
//  AppTheme.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/21/26.
//

import SwiftUI

enum AppTheme {
    
    static let backgroundGradient = LinearGradient (
        colors: [
            Color(red: 0.29, green: 0.53, blue: 0.52),   // deep teal
            Color(red: 0.34, green: 0.58, blue: 0.57),   // mid teal
            Color(red: 0.42, green: 0.64, blue: 0.62),   // soft seafoam
            Color(red: 0.51, green: 0.71, blue: 0.68)    // light aqua
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
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
