//
//  RoutineHomeView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/21/26.
//

import SwiftUI
import SwiftData

struct RoutineHomeView: View {
    @StateObject private var router = AppRouter()
    @Environment(\.modelContext) private var modelContext
    
    @Query private var routines: [Routine]

    private var currentRoutine: Routine? {
        routines.first
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationBarTitleDisplayMode(.inline)
        }
        .task(){
            if let routine = currentRoutine {
                
                if let compDate = routine.completeDate,
                   !Calendar.current.isDate(compDate, inSameDayAs: Date()){
                    
                    if !routine.routines.isEmpty {
                        routine.routines.filter{ task in
                            guard let date = task.completeDate else { return false }
                            return !Calendar.current.isDate(date, inSameDayAs: Date())
                        }
                        .forEach(){ $0.doneToday = false }
                        
                        try? modelContext.save()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea(.all)
            Group {
                switch router.currentScreen {
                case .routineHome:
                    Group {
                        if let compDate = currentRoutine?.completeDate,
                           Calendar.current.isDate(compDate, inSameDayAs: Date()) {
                            compScreen
                        } else if let routine = currentRoutine, !routine.routines.isEmpty {
                            RoutineSummaryView(routine: routine, router: router)
                        } else {
                            introScreen
                        }
                    }
                    .id("routineHome")
                    .zIndex(0)

                case .createRoutine:
                    CreateRoutineView(router: router)
                        .id("createRoutine")
                        .transition(
                            .asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                )
                        )
                        .zIndex(1)

                case .previewRoutine(let tasks):
                    PreviewRoutineView(router: router, tasks: tasks)
                        .id("previewRoutine")
                        .transition(
                            .asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                )
                        )
                        .zIndex(1)

                case .editRoutine(let routine):
                    EditRoutineView(routine: routine, router: router)
                        .toolbar(.hidden, for: .tabBar)
                        .transition(
                            .asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                )
                        )
                        .id("editRoutine")
                        .zIndex(1)

                case .routineSession(let routine):
                    RoutineSessionView(routine: routine, router: router)
                        .toolbar(.hidden, for: .tabBar)
                        .transition(
                            .asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                )
                        )
                        .id("routineSession")
                        .zIndex(2) // Kept higher than routineHome so it overlays cleanly on top
                }
            }
        }

    }
    
    private var introScreen: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                
                HeaderView()
                Spacer()
                
                VStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.tint)
                        .tint(AppTheme.defaultIconTint)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                    
                    Text("Build a routine made of tasks\nthat add up to exactly \(AppConstants.totalRoutineMinutes) minutes.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.textSecondary)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                }.padding()
                
                Spacer()
                
                VStack {
                    Button {
                        router.goToCreateRoutine()
                    } label: {
                        Text("Create 1-Hour Routine")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.backgroundGradient)
                    .controlSize(.regular)
                    .modifier(AppButtonModifiler())
                    
                }.padding()
                Spacer().frame(height: 10)
            }
            
        }
    }
    
    private var compScreen: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea(.all)
            
            VStack(spacing: 20) {
                
                HeaderView()
                Spacer()
                
                VStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.tint)
                        .tint(AppTheme.defaultIconTint)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                    
                    Text("You have completed today's routine!")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                }.padding()
                
                Spacer()
                
                VStack {
                    Button {
                        if let rountine = currentRoutine {
                            router.goToEditRoutine(routine: rountine)
                        }
                    } label: {
                        Text("Edit routine")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.backgroundGradient)
                    .controlSize(.regular)
                    .modifier(AppButtonModifiler())
                }.padding()
                Spacer().frame(height: 10)
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var appRouter = AppRouter()
    @Previewable @Query var rutines:[Routine]
    
    let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: ATask.self, DailyProgress.self, DailyBreak.self, Routine.self,
            ActionIcon.self,
            configurations: config
        )
        
        let context = container.mainContext
        
        let samepleTasks: [RTask] = [
//            RTask(minutes: 1, routine_description: "Read a book ...", order: 0),
//            RTask(minutes: 1, routine_description: "Exercise your muscle1 ...", order: 1),
//            RTask(minutes: 1, routine_description: "Take a shower", order: 2),
        ]
        
        samepleTasks.forEach(){ $0.doneToday = false }
        
        let sampleRoutine = Routine(routines: samepleTasks)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        sampleRoutine.completeDate = yesterday
        context.insert(sampleRoutine)
        
        return container
    }()
    
    RoutineHomeView()
        .modelContainer(container)
        .environmentObject(appRouter)
    
}
