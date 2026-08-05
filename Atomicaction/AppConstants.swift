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
    
    
    static let totalRoutineMinutes: Int = 5
    static let routineDuration: Int = 1
    
    static let totalTaskMinutes: Int = 5
    static let taskDuration: Int = 1
}
