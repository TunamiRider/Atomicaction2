//
//  MainView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/15/26.
//
import SwiftUI
import SwiftData
struct MainView: View {
    
    var body: some View {
        TabView {
            NavigationStack {
                ContentView()
            }
            .tabItem {
                Label("Action", systemImage: "square.and.pencil")
            }
            .tag(0)
            
            NavigationStack {
                RoutineHomeView()
            }
            .tabItem {
                Label("Routine", systemImage: "clock")
                    .environment(\.symbolVariants, .none)
            }
            .tag(1)

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("Completed", systemImage: "circle.badge.checkmark")
                    .environment(\.symbolVariants, .none)
            }
            .tag(2)
            
            NavigationStack {
                TodayProgressView()
            }
            .tabItem {
                Label("Progress", systemImage: "chart.pie")
                    .environment(\.symbolVariants, .none)
            }
            .tag(3)
            
        }.tint(.white)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: ATask.self, DailyProgress.self, DailyBreak.self,  Routine.self,// <-- register both models
        configurations: config
    )
    
    let now = Date()
    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
    
    let twodaysago = Calendar.current.date(byAdding: .day, value: -2, to: now)!
    let threedaysago = Calendar.current.date(byAdding: .day, value: -5, to: now)!

    let sampleTasks: [ATask] = [
//        ATask(
//            title: "Morning Meditation",
//            minutes: 60*13,
//            descriptionMode: .plain,
//            task_description: "Sit quietly, focus on breathing, and let thoughts pass without judgment.",
//            steps: [],
//            timestamp: threedaysago.addingTimeInterval(-3600 * 6)
//        ),
//        ATask(
//            title: "Morning Meditation",
//            minutes: 60,
//            descriptionMode: .plain,
//            task_description: "Sit quietly, focus on breathing, and let thoughts pass without judgment.",
//            steps: [],
//            timestamp: twodaysago.addingTimeInterval(-3600 * 6)
//        ),
//        ATask(
//            title: "Morning Meditation",
//            minutes: 30,
//            descriptionMode: .plain,
//            task_description: "Sit quietly, focus on breathing, and let thoughts pass without judgment.",
//            steps: [],
//            timestamp: twodaysago.addingTimeInterval(-3600 * 5)
//        ),
//        ATask(
//            title: "Cook Pasta Dinner",
//            minutes: 40,
//            descriptionMode: .steps,
//            task_description: "",
//            steps: [
//                "Boil water and add salt",
//                "Cook pasta for 9 minutes",
//                "Prepare the sauce separately",
//                "Combine pasta and sauce",
//                "Serve with parmesan on top"
//            ],
//            timestamp: twodaysago.addingTimeInterval(-3600 * 3)
//        ),
//        ATask(
//            title: "Read a Book Chapter",
//            minutes: 30,
//            descriptionMode: .plain,
//            task_description: "Continue reading from where I left off yesterday, take notes on key ideas.",
//            steps: [],
//            timestamp: yesterday.addingTimeInterval(-3600 * 1.5)
//        ),
//        ATask(
//            title: "Clean the Kitchen",
//            minutes: 30,
//            descriptionMode: .steps,
//            task_description: "",
//            steps: [
//                "Wash dishes",
//                "Wipe countertops",
//                "Sweep the floor",
//                "Take out trash"
//            ],
//            timestamp: yesterday.addingTimeInterval(-1800)
//        ),
//        ATask(
//            title: "Quick Stretch",
//            minutes: 40,
//            descriptionMode: .plain,
//            task_description: "",
//            steps: [],
//            timestamp: Date().addingTimeInterval(-3600 * 9)
//        ),
//        ATask(
//            title: "Quick Stretch",
//            minutes: 40,
//            descriptionMode: .plain,
//            task_description: "",
//            steps: [],
//            timestamp: Date()
//        ),
//        ATask(
//            title: "Quick Stretch3",
//            minutes: 20,
//            descriptionMode: .plain,
//            task_description: "",
//            steps: [],
//            timestamp: Date().addingTimeInterval(3600)
//        ),
//        ATask(
//            title: "Quick Stretch4",
//            minutes: 10,
//            descriptionMode: .plain,
//            task_description: "",
//            steps: [],
//            timestamp: Date().addingTimeInterval(3600)
//        ),
        
    ]

    for task in sampleTasks {
        container.mainContext.insert(task)
    }

    // Group sample tasks by the calendar day they actually fall on,
    // then create one DailyProgress per day instead of dumping everything into "today".
    let entriesByDay = Dictionary(grouping: sampleTasks) {
        Calendar.current.startOfDay(for: $0.timestamp)
    }

    for (day, tasks) in entriesByDay {
        let entries = tasks.map {
            TaskEntry(taskTitle: $0.title, minutes: $0.minutes, completedAt: $0.timestamp)
        }
        let progress = DailyProgress(date: day, entries: entries)
        container.mainContext.insert(progress)
    }

    
    return MainView()
        .modelContainer(container)
}
