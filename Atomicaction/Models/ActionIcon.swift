//
//  ActionIcon.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 8/18/26.
//

import SwiftUI
import SwiftData

@Model
final class ActionIcon : Identifiable{
    var systemName: String
    var hexCode: String
    var isSelected: Bool
    
    init(systemName: String, hexCode: String, isSelected: Bool = false){
        self.systemName = systemName
        self.hexCode = hexCode
        self.isSelected = isSelected
    }
    
    var color: Color {
        Color(hex: hexCode)
    }
}
