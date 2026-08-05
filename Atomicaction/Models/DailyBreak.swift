//
//  DailyBreak.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/21/26.
//

import Foundation
import SwiftData

@Model
final class DailyBreak {
    var date: Date
    var averageBreakMinutes: Double
    var breakCount: Int
    
    init(date: Date, averageBreakMinutes: Double = 0, breakCount:Int = 0){
        self.date = date
        self.averageBreakMinutes = averageBreakMinutes
        self.breakCount = breakCount
    }
}
