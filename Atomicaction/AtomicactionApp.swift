//
//  AtomicactionApp.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/14/26.
//

import SwiftUI
import SwiftData

@main
struct AtomicactionApp: App {

    
    var body: some Scene {
        WindowGroup {
            MainView()
        }.modelContainer(for: [ATask.self, DailyProgress.self])
    }
}
