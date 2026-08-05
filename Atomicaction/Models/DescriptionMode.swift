//
//  DescriptionMode.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/15/26.
//

// MARK: - Description mode
enum DescriptionMode: String, CaseIterable, Codable {
    case plain = "Note"
    case steps = "Steps"
    case routine = "Routine"
}
