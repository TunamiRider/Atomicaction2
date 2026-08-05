//
//  Task.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/15/26.
//

import SwiftData
import Foundation
@Model
class ATask {
    
    var title: String
    var minutes: Int
    var descriptionMode: DescriptionMode
    var task_description: String
    var steps: [String]
    var timestamp: Date
    
    init(title: String, minutes: Int, descriptionMode: DescriptionMode, task_description: String, steps: [String], timestamp: Date) {
        self.title = title
        self.minutes = minutes
        self.descriptionMode = descriptionMode
        self.task_description = task_description
        self.steps = steps
        self.timestamp = timestamp
    }
}
