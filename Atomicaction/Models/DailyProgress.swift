//
//  DailyProgress.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/17/26.
//

import SwiftData
import Foundation

// A lightweight, non-Model struct — just data, stored inline on DailyProgress.
// SwiftData can persist arrays of Codable structs directly, no separate table needed.
struct TaskEntry: Codable {
    var taskTitle: String
    var minutes: Int
    var completedAt: Date
}

@Model
final class DailyProgress {
    var date: Date            // normalized to startOfDay — acts as the unique key for the day
    var entries: [TaskEntry]  // every task completed that day

    init(date: Date, entries: [TaskEntry] = []) {
        self.date = date
        self.entries = entries
    }

    var totalTasksCompleted: Int {
        entries.count
    }

    var totalMinutes: Int {
        entries.reduce(0) { $0 + $1.minutes }
    }
}
