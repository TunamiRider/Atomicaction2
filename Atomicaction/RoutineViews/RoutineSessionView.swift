//
//  RoutineSessionView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/23/26.
//

import SwiftUI
import SwiftData

struct RoutineSessionView: View {
    let routine: Routine
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var router: AppRouter
    @State private var currentIndex = 0
    @State private var title = ""
    @State private var description = ""
    @State private var minutes = 1
    @State private var descriptionMode: DescriptionMode = .routine
    @State private var steps: [String] = [""]
    @State private var isAllRountineDone = false
    @Environment(\.modelContext) private var modelContext

    private var tasks: [RTask] {
        routine.sortedTasks.filter{ $0.doneToday == false }
    }

    private var currentTask: RTask? {
        guard tasks.indices.contains(currentIndex) else { return nil }
        return tasks[currentIndex]
    }
    
    private var done: Bool {
         currentIndex == tasks.count
        //(routine.sortedTasks.filter{ $0.doneToday == false }.count == 0) ||
    }

    var body: some View {
        Group {
            if let task = currentTask, !done {
                SeaSaltTimer2(
                    title: $title,
                    description: $description,
                    minutes: $minutes,
                    descriptionMode: $descriptionMode,
                    steps: $steps,
                    onComplete: {complete in
                        
                        
                        goNext(complete: complete)
                    }
                )
                .id(task.id)
                .task(id: task.id){
                    load(task)
                }
                // Overlay the back button directly on top of SeaSaltTimer2
//                        .overlay(alignment: .topLeading) {
//                            Button {
//                                router.goToRoutineHome()
//                            } label: {
//                                HStack {
//                                    Image(systemName: "chevron.backward")
//                                        .font(.system(size: 20, weight: .bold)) // Bigger and bolder icon
//                                        .foregroundStyle(Color.white.opacity(0.8))
//                                        .shadow(color: .black.opacity(0.3), radius: 2) // Optional icon pop
//                                }
//                                .padding(12) // Adds space inside the button for a bigger overall size
//                            }
//                            .buttonStyle(.borderedProminent)
//                            .tint(AppTheme.backgroundGradient)
//                            .frame(width: 42, height: 42)
//                            .clipShape(Circle())
//                            .overlay(
//                                Circle()
//                                    .stroke(Color.white.opacity(0.8), lineWidth: 1)
//                            )
//                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
//                            .padding(.top, 8)
//                            .padding(.leading, 16)
//                        }
//                .onChange(of: task.id, initial: true) {
//                    load(task)
//                }
            } else {
                VStack(spacing: 16) {
                    
                    if tasks.count == 0 {
                        Text("Great job🎉")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                            .padding(.bottom, -8)
                        Text("All Routines are complete.")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                    }else {
                        Text("Routine complete!")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                    }

                    Button {
                        router.goToRoutineHome()
                    } label: {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.backgroundGradient)
                    .controlSize(.regular)
                    .modifier(AppButtonModifiler())
                    .padding(.horizontal, 128)
                    

                    
                    if tasks.count == 0 {
                    }else {
                        Text("The following are the skipped routines.")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                            .padding(.top, 80)
                        VStack(alignment: .leading) {
                            ForEach(tasks, id: \.self){ task in
                                Text("• \(task.routine_description)")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                //.frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                            }
                            .padding(.horizontal, 32)
                        }.padding(.horizontal)
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.backgroundGradient.ignoresSafeArea())
            }
        }
        .navigationBarBackButtonHidden(true)
        //.toolbar(.hidden, for: .navigationBar)
        .toolbar {
            if !isAllRountineDone {
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        //withAnimation(.easeIn(duration: 1)) {
                        
                        router.goToRoutineHome()
                        //}
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppTheme.backgroundGradient)
                    //.modifier(AppButtonModifiler())
                    //.disabled(totalMinutes != 60)
                    .disabled(isAllRountineDone)
                    .opacity(isAllRountineDone ? 0 : 1)
            }
            }
        }

    }

    private func load(_ task: RTask) {
        title = task.routine_description
        description = task.routine_description
        minutes = task.minutes
        descriptionMode = .routine
        steps = [task.routine_description]
    }

    private func goNext(complete: Bool) {
        
        print("currentIndex : \(currentIndex) == \(routine.sortedTasks.count)")
        print("tasks.count : \(tasks.count)")
        
        if complete && currentIndex + 1 <= tasks.count {
            tasks[currentIndex].doneToday = true
            try? modelContext.save()
            currentIndex -= 1
        }
        
        if tasks.count == 0 {
            routine.completeDate = Date()
            try? modelContext.save()
            print("All routines are done.")
        }
        
        
        if currentIndex + 1 < tasks.count {
            currentIndex += 1
        } else {
            print("dismiss")
            isAllRountineDone = true
//            dismiss()
            currentIndex += 1
        }
        
        
//        if currentIndex + 1 == tasks.count {
//            isAllRountineDone = true
//            dismiss()
//        }
    }
}


#Preview {
    @Previewable @StateObject var appRouter = AppRouter()
    @Previewable @Query var rutines:[Routine]
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: ATask.self, DailyProgress.self, DailyBreak.self,  Routine.self,// <-- register both models
        configurations: config
    )
    
    
    let sampleTasks: [RTask] = [ RTask(minutes: 1, routine_description: "Test 1 Test 1 Test 1 Test 1 Test 1 Test 1 Test 1 Test 1 Test 1 Test 1"),
//                                 RTask(minutes: 1, routine_description: "Test 2"),
//                                 
//                                 RTask(minutes: 1, routine_description: "Test 3"),
                                
                                 
    ]
    let sampleRoutine = Routine(routines: sampleTasks)
    
    
    RoutineSessionView(routine: sampleRoutine, router:appRouter).modelContainer(container)
}
