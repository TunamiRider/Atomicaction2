//
//  AppRouter.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/22/26.
//

import SwiftUI
import Combine
enum RootScreen {
    case routineHome
    case createRoutine
    case previewRoutine(tasks: [RTask])
    case editRoutine(routine: Routine)
    case routineSession(routine: Routine)
}

final class AppRouter: ObservableObject {
    @Published var currentScreen: RootScreen = .routineHome

    func goToRoutineHome() {
        currentScreen = .routineHome
    }

    func goToCreateRoutine() {
        currentScreen = .createRoutine
    }

    func goToPreview(tasks: [RTask]) {
        currentScreen = .previewRoutine(tasks: tasks)
    }
    
    func goToEditRoutine(routine: Routine) {
        currentScreen = .editRoutine(routine: routine)
    }
    
    func goToRoutineSession(routine: Routine){
        currentScreen = .routineSession(routine: routine)
    }
}
