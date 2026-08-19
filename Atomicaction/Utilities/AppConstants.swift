//
//  AppConstants.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/24/26.
//

import SwiftUI

struct AppConstants {
    
    static let gradient = RoundedRectangle(cornerRadius: 30, style: .continuous)
        .fill(
            LinearGradient(
                colors: [.white.opacity(0.4), .clear],
                startPoint: .top,
                endPoint: .center
            )
        )
    
    
    static let totalRoutineMinutes: Int = 5 // 60 5
    static let initialRoutineDuration: Int = 1 // 10 1
    static let stepRoutineDuration: Int = 1 // 10 1
    
    static let maxTaskMinutes: Int = 60 // 5
    static let initialTaskDuration: Int = 1 // 10 1
    static let stepTaskDuration: Int = 1 // 5 1
    
    
    
    
    static let whiteColor: Color = Color(red: 0.0, green: 0.00, blue: 0.00)
    
    // Cycle through these colors in order, same order the tasks are stored.
    static let palette: [Color] = [
        Color(red: 0.10, green: 0.45, blue: 0.45), // dark teal
        Color(red: 0.55, green: 0.78, blue: 0.90), // light blue
        Color(red: 0.35, green: 0.75, blue: 0.45), // green
        Color(red: 0.95, green: 0.75, blue: 0.30), // yellow
        Color(red: 0.95, green: 0.60, blue: 0.25), // orange

        Color(red: 0.75, green: 0.40, blue: 0.55), // rose
        Color(red: 0.60, green: 0.50, blue: 0.80), // lavender
        Color(red: 0.30, green: 0.50, blue: 0.70), // steel blue
        Color(red: 0.20, green: 0.30, blue: 0.45), // deep navy
        Color(red: 0.80, green: 0.40, blue: 0.20)  // terra cotta
    ]
    
    // Cycles in lockstep with `palette` — index i's icon always pairs with index i's color.
    static let iconPalette: [String] = [
        "book.fill",
        "figure.walk",
        "leaf.fill",
        "cup.and.saucer.fill",
        "flame.fill",
        "heart.fill",
        "moon.stars.fill",
        "drop.fill",
        "pencil",
        "sun.max.fill"
    ]
}
