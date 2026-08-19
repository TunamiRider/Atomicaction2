//
//  IconDataHelper.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 8/18/26.
//

import SwiftData
import SwiftUI

enum IconDataHelper {
    
    
    @MainActor
    static func seedIconDataIfNeeded(in context: ModelContext) {
        
        let descriptor = FetchDescriptor<ActionIcon>()
        
        let count = (try? context.fetchCount(descriptor)) ?? 0
        
        
        guard count == 0 else { return }
        
        let defaultPaletteHexes = [
            "#0096FF", // "book.fill"           -> Electric Blue (Focus / Reading)
            "#00A896", // "figure.walk"         -> Caribbean Teal (Active / Fitness)
            "#10B981", // "leaf.fill"           -> Emerald Green (Nature / Health)
            "#FF6B00", // "cup.and.saucer.fill"  -> Flame Orange (Warm Coffee / Tea)
            "#FF3B30", // "flame.fill"          -> Vibrant Red (Energy / Streak)
            "#E91E63", // "heart.fill"          -> Magenta Pink (Care / Health)
            "#8A2BE2", // "moon.stars.fill"     -> Royal Purple (Night / Rest)
            "#00D2FF", // "drop.fill"           -> Bright Cyan (Water / Hydration)
            "#7C3AED", // "pencil"              -> Deep Violet (Creative / Writing)
            "#FFB800"  // "sun.max.fill"        -> Golden Yellow (Day / Morning)
        ]
        
        let defaultIconPalettes: [String] = [
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
        
        
        for (index, iconStr) in defaultIconPalettes.enumerated() {
            let hexCode = defaultPaletteHexes[index % defaultPaletteHexes.count]
            
            let actionIcon = ActionIcon(systemName: iconStr, hexCode: hexCode, isSelected: false)
            
            context.insert(actionIcon)
        }
        
        do {
                try context.save()
            } catch {
                print("Failed to save seeded icons: \(error)")
            }
    }
    
    
    
    @MainActor
    static func toggleActionIconSelected(in actionIcon: ActionIcon, in context: ModelContext){
        actionIcon.isSelected.toggle()
        
        try? context.save()
    }
}


//extension Color {
//    init(hex: String) {
//        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: cleanHex).scanHexInt64(&int)
//        
//        let a, r, g, b: UInt64
//        switch cleanHex.count {
//        case 6: // RGB (24-bit) — e.g. "#1A7373"
//            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit) — e.g. "#FF1A7373"
//            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
//        default: // Fallback to black on invalid hex
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}

extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        // Using .sRGBLinear or displayP3 produces accurate color vibrancy on iOS screens
        self.init(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: Double(a) / 255.0
        )
    }
}
