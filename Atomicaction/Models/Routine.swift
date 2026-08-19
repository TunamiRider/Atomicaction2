//
//  Routine.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/21/26.
//

import SwiftData
import Foundation

@Model
final class Routine {
    var routines: [RTask]
    var completeDate: Date?
    
    init (routines: [RTask] = []){
        self.routines = routines
        self.completeDate = Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now
    }
    
    var sortedTasks: [RTask] {
        routines.sorted{ $0.order < $1.order }
    }
}

@Model
class RTask: Identifiable{
    var id: UUID = UUID()
    var minutes: Int
    var routine_description: String
    var order: Int
    var doneToday: Bool
    var icon: ActionIcon
    var completeDate: Date?
    
    
    init(minutes:Int, routine_description: String, order: Int = 0, doneToday: Bool = false, icon: ActionIcon = ActionIcon(systemName: "book.fill", hexCode: "#1A7373")){
        self.minutes = minutes
        self.routine_description = routine_description
        self.order = order
        self.doneToday = doneToday
        self.icon = icon
    }
}
