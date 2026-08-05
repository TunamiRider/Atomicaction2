//
//  EditRoutineView.swift
//  Atomicaction
//
//  Created by Yuki Suzuki on 7/22/26.
//

import SwiftUI
import SwiftData

struct EditRoutineView: View {
    @Bindable var routine: Routine
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var router: AppRouter

    @State private var showingAddTask = false
    @State private var selectedTask: RTask?
    
    private var totalMinutes: Int {
        routine.routines.reduce(0) { $0 + $1.minutes }
    }
    private var remainingMinutes: Int {
        AppConstants.totalRoutineMinutes - totalMinutes
    }
    private var IsTotalMinutes60: Bool {
        totalMinutes == AppConstants.totalRoutineMinutes
    }

//    var body: some View {
//        ScrollView(.vertical, showsIndicators: false)  {
//
//            Section {
//                ForEach(routine.routines) { task in
//                    Button {
//                        selectedTask = task
//                    } label: {
//                        HStack {
//                            VStack(alignment: .leading, spacing: 4) {
//                                Text(task.routine_description)
//                                    .font(.body)
//                                    .lineLimit(2)
//                                    .foregroundStyle(.white.opacity(0.8))
//                                Text("\(task.minutes) min")
//                                    .font(.caption)
//                                    .foregroundStyle(.white.opacity(0.4))
//                            }
//
//                            Spacer()
//
//                            Image(systemName: "pencil")
//                                .font(.caption.weight(.semibold))
//                                .foregroundStyle(.white.opacity(0.8))
//                        }
//                        .padding(.vertical, 8)
//                        .padding(.horizontal, 12)
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(Color.black.opacity(0.3))
//                        )
//                        .contentShape(Rectangle())
//                        
//                    }
//                    .buttonStyle(.plain)
//                    
//                }
//                .onDelete(perform: deleteTasks)
//                .onMove(perform: moveTasks)
//            }header: {
//               HStack {
//                   Text("Tasks (\(routine.routines.count)/10)")
//                       .foregroundStyle(.white.opacity(0.8))
//                       .fontWeight(.semibold)
//                   Spacer()
//                   Text("\(totalMinutes) / 60 min")
//                       .foregroundStyle(totalMinutes == 60 ? .white.opacity(0.8) : .secondary)
//                       .fontWeight(.semibold)
//               }
//            }
//            .padding()
//            
//        }
//        .navigationTitle("Edit Routine")
//        .navigationBarTitleDisplayMode(.inline)
//        .scrollContentBackground(.hidden)
//        .toolbarColorScheme(.dark, for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
//        .navigationBarBackButtonHidden(true)
//        .background(AppTheme.backgroundGradient.ignoresSafeArea())
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    showingAddTask = true
//                } label: {
//                    Image(systemName: "plus")
//                }
//            }
//        }
//        
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button {
//                    router.goToRoutineHome()
//                } label: {
//                    HStack(spacing: 4) {
//                        Image(systemName: "chevron.backward")
//                    }
//                }
//            }
//        }
//        .sheet(isPresented: $showingAddTask) {
//            NavigationStack {
//                //AddTaskView2(routine: routine)
//                AddTaskView(remainingMinutes: 60 - totalMinutes) { newTask in
//                    routine.routines.append(newTask)
//                }
//            }
//        }
//        .sheet(item: $selectedTask) { task in
//            NavigationStack {
//                EditTaskView(task: task)
//            }
//        }
//    }
    
    
    var body: some View {
        List {
            Section {
                ForEach(routine.sortedTasks) { task in
                    Button {
                        selectedTask = task
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.routine_description)
                                    .font(.body)
                                    .lineLimit(2)
                                    .foregroundStyle(.white.opacity(0.8))

                                Text("\(task.minutes) min")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.4))
                            }

                            Spacer()

                            Image(systemName: "pencil")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.3))
                        )
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 4, trailing: 8))

                }
                .onDelete(perform: deleteTasks)
                .onMove(perform: moveTasks)
            } header: {
                HStack {
                    Text("Tasks (\(routine.routines.count)/10)")
                        .foregroundStyle(.white.opacity(0.8))
                        .fontWeight(.semibold)

                    Spacer()

                    Text("\(totalMinutes) / \(AppConstants.totalRoutineMinutes) min")
                        .foregroundStyle(IsTotalMinutes60 ? .white.opacity(0.8) : .secondary)
                        .fontWeight(.semibold)
                }
            }
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            
            if !IsTotalMinutes60 {
                Text("Total routine time doesn’t add up to \(AppConstants.totalRoutineMinutes) minutes.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)            // hide list’s own background
        .background(AppTheme.backgroundGradient)     // match outer view
        .navigationTitle("Edit Routine")
        .navigationBarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .listRowSpacing(0)
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddTask = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.white)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.backgroundGradient)
            }
        }
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    router.goToRoutineHome()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.white)
                    }
                    
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.backgroundGradient)
                .disabled(totalMinutes != AppConstants.totalRoutineMinutes)
            }
        }
        .sheet(isPresented: $showingAddTask) {
            NavigationStack {
                //AddTaskView2(routine: routine)
                AddTaskView(remainingMinutes: remainingMinutes) { newTask in
                    let nextOrderIndex = routine.routines.count
                    newTask.order = nextOrderIndex
                    routine.routines.append(newTask)
                }
            }
        }
        .sheet(item: $selectedTask) { task in
            NavigationStack {
                EditTaskView(task: task, remainingMinutes: remainingMinutes)
            }
        }
    }


    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = routine.routines[index]
            modelContext.delete(task)
        }
        routine.routines.remove(atOffsets: offsets)
    }

    private func moveTasks(from source: IndexSet, to destination: Int) {
        routine.routines.move(fromOffsets: source, toOffset: destination)
    }
}

struct EditTaskView: View {
    @Bindable var task: RTask
    let remainingMinutes: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            TextField("Description", text: $task.routine_description, axis: .vertical)
            Stepper("Minutes: \(task.minutes)",value: $task.minutes,in: AppConstants.routineDuration...max(AppConstants.routineDuration, remainingMinutes+task.minutes),step: AppConstants.routineDuration)
        }
        .navigationTitle("Edit Task")
        .scrollContentBackground(.hidden)   // 👈 tells Form to stop drawing its own background
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
    }
}

struct AddTaskView2: View {
    let routine: Routine
    @Environment(\.dismiss) private var dismiss

    @State private var description = ""
    @State private var minutes = 5

    var body: some View {
        Form {
            TextField("Description", text: $description)
            Stepper("Minutes: \(minutes)", value: $minutes, in: 1...180)
        }
        .navigationTitle("Add Task")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    let newTask = RTask(minutes: minutes, routine_description: description)
                    routine.routines.append(newTask)
                    dismiss()
                }
                .disabled(description.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
                    
            }
        }
    }
}


#Preview {
    @Previewable @StateObject var appRouter = AppRouter()
    @Previewable @Query var rutines: [Routine]

    let sampleTasks: [RTask] = [
        RTask(minutes: 5, routine_description: "Read a book Read a book Read a book Read a book Read a book Read a book Read a book Read a book Read a book "),
        RTask(minutes: 5, routine_description: "Exercise your muscle1 aaaaaaaa dddddd ffffff   ddwdwwqrqrqdrwqrv3q fewnrew;uo griowf;ntfeia grientferuisof fheionferi"),
        RTask(minutes: 5, routine_description: "Exercise your muscle2"),
        RTask(minutes: 5, routine_description: "Exercise your muscle3"),
        RTask(minutes: 5, routine_description: "Exercise your muscl4"),
        RTask(minutes: 5, routine_description: "Exercise your muscle4"),
        RTask(minutes: 5, routine_description: "Exercise your muscle5"),
        RTask(minutes: 5, routine_description: "Exercise your muscle6"),
        RTask(minutes: 10, routine_description: "Exercise your muscle7"),
        RTask(minutes: 10, routine_description: "Exercise your muscle8"),
    ]
    let sampleRoutine = Routine(routines: sampleTasks)

    NavigationStack {
        EditRoutineView(routine: sampleRoutine, router: appRouter)
    }
}
