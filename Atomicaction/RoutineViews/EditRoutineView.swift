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

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient.ignoresSafeArea(.all)
            VStack(spacing: 0) {
                HStack{
                    Button {
                        router.navigateTo(.routineHome)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.backward")
                                .circularIconStyle()
//                                .renderingMode(.template)
//                                .font(.system(size: 16, weight: .semibold))
//                                .foregroundStyle(.white)
//                                .frame(width: 28, height: 28)
//                                .buttonStyle(.borderedProminent)
//                                .tint(AppTheme.backgroundGradient)
//                                .background(AppTheme.backgroundGradient)
//                                .clipShape(Circle())
//                                .overlay(
//                                    Circle()
//                                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
//                                )
//                                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                        }
                    }
                    .clipShape(Circle())
                    .disabled(totalMinutes != AppConstants.totalRoutineMinutes)
                    
                    Spacer()
                    Text("Edit Task")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                    Spacer()
                    
                    
                    Button {
                        showingAddTask = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .circularIconStyle()
//                                .renderingMode(.template)
//                                .font(.system(size: 16, weight: .semibold))
//                                .foregroundStyle(.white)
//                                .frame(width: 28, height: 28)
//                                .buttonStyle(.borderedProminent)
//                                .tint(AppTheme.backgroundGradient)
//                                .clipShape(Circle())
//                                .overlay(
//                                    Circle()
//                                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
//                                )
//                                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
                        }
                    }
                    .clipShape(Circle())
                }
                .padding(.horizontal, 32)
                .padding(.top, 16)
                
                List {
                    Section {
                        ForEach(routine.sortedTasks) { task in
                            Button {
                                selectedTask = task
                            } label: {
                                HStack {
                                    Image(systemName: task.icon.systemName)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40) // Fixed frame aligns all icons vertically
                                        .background(
                                            Circle()
                                                .fill(task.icon.color.opacity(0.2))
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(task.icon.color, lineWidth: 2) // Fixed: Added hex initializer
                                        )
                                    
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
                .navigationTitle("Edit Routine")
                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackground(.hidden)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
                .listRowSpacing(0)
                .sheet(isPresented: $showingAddTask) {
                    NavigationStack {
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
                .toolbar(.hidden, for: .navigationBar)
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
    
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<ActionIcon>{ $0.isSelected == false}) private var actionIcons: [ActionIcon]
    @State private var selectedActionIcon: ActionIcon = ActionIcon(systemName: "book.fill", hexCode: "#1A7373")
    private let columns = [GridItem(.adaptive(minimum: 60), spacing: 10)]
    
    var body: some View {
        Form {
            //TextField("Description", text: $task.routine_description, axis: .vertical)
            
            TextField("Description", text: $task.routine_description, axis: .vertical)
                .onChange(of: task.routine_description) { oldValue, newValue in
                    if newValue.count > 60 {
                        task.routine_description = String(newValue.prefix(60))
                    }
                }
                .foregroundStyle(.black)
                .tint(.black)
            
            Stepper("Minutes: \(task.minutes)",value: $task.minutes,in: AppConstants.initialRoutineDuration...max(AppConstants.initialRoutineDuration, remainingMinutes+task.minutes),step: AppConstants.stepRoutineDuration)
            
            LazyVGrid(columns: columns, spacing: 24) {
                
                ForEach(actionIcons, id: \.self){ icon in
                    CircleIcon(
                                actionIcon: icon,
                                isSelected: task.icon.systemName == icon.systemName
                            ) {
                                
                                    task.icon.isSelected = false
                                    task.icon = icon
                            }
                }
            }
        }
        .navigationTitle("Edit Task")
        .scrollContentBackground(.hidden)   // 👈 tells Form to stop drawing its own background
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    task.icon.isSelected = true
                    dismiss()
                }
            }
        }
        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
        .task{            
            selectedActionIcon = actionIcons.first ?? ActionIcon(systemName: "book.fill", hexCode: "#1A7373")
        }
    }

}
private struct CircleIcon: View {
    let actionIcon: ActionIcon
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Image(systemName: actionIcon.systemName)
            .font(.system(size: 22))
            .foregroundColor(.white)
            .opacity(isSelected ? 1.0 : 0.4)
            .padding(10)
            .background(
                Circle()
                    .fill(isSelected ? actionIcon.color.opacity(0.2) : Color.gray.opacity(1.0))
            )
            .overlay(
                Circle()
                    .stroke(isSelected ? actionIcon.color : Color.gray.opacity(1.0), lineWidth: 2)
            )
            .onTapGesture(perform: onTap)
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
